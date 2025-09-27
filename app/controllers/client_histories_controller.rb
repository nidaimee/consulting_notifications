class ClientHistoriesController < ApplicationController
  include TailadminLayout
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_history, only: [ :show, :edit, :update, :destroy ]
  # ✅ ADICIONAR esta linha

  def index
    # ✅ OTIMIZADO: Lista com includes e paginação
    @client_histories = @client.client_histories
                              .includes(:user, images_attachments: :blob)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(20)

    # ✅ Cache das estatísticas do histórico
    @history_stats = Rails.cache.fetch("client_#{@client.id}_history_stats", expires_in: 10.minutes) do
      calculate_history_stats
    end
  end

  def show
    # ✅ OTIMIZADO: Já carregado com includes no set_client_history
  end

  def new
    @client_history = @client.client_histories.build
  end

  def create
    @client_history = @client.client_histories.build(client_history_params)

    # ✅ OTIMIZADO: Transação para consistência
    ActiveRecord::Base.transaction do
      if @client_history.save
        # ✅ Processar uploads de imagens em background
        if client_history_params[:images].present?
          ProcessHistoryImagesJob.perform_later(@client_history, client_history_params[:images])
        end

        # ✅ Atualizar cache de estatísticas
        expire_client_caches

        # ✅ Atualizar último contato do cliente automaticamente
        @client.touch(:last_contacted_at) if should_update_last_contact?

        redirect_to @client, notice: "Entrada de histórico adicionada com sucesso!"
      else
        Rails.logger.error "Client history validation errors: #{@client_history.errors.full_messages}"

        # ✅ Re-carregar dados necessários para re-renderizar
        load_client_data_for_show
        flash.now[:alert] = "Erro ao adicionar entrada: #{@client_history.errors.full_messages.join(', ')}"
        render "clients/show", status: :unprocessable_entity
      end
    end

  rescue => e
    Rails.logger.error "Error creating client history: #{e.message}"
    redirect_to @client, alert: "Erro inesperado ao adicionar entrada. Tente novamente."
  end

  def edit
    # ✅ OTIMIZADO: Já carregado com includes
  end

  def update
    # ✅ OTIMIZADO: Usar transação e validações melhoradas
    ActiveRecord::Base.transaction do
      if @client_history.update(client_history_params)
        # ✅ Processar novas imagens em background
        if client_history_params[:images].present?
          ProcessHistoryImagesJob.perform_later(@client_history, client_history_params[:images])
        end

        expire_client_caches
        redirect_to @client, notice: "Histórico atualizado com sucesso."
      else
        Rails.logger.error "Client history update errors: #{@client_history.errors.full_messages}"

        # ✅ Re-carregar dados para renderizar corretamente
        load_client_data_for_show
        flash.now[:alert] = "Erro ao atualizar histórico: #{@client_history.errors.full_messages.join(', ')}"
        render "clients/show", status: :unprocessable_entity
      end
    end

  rescue => e
    Rails.logger.error "Error updating client history: #{e.message}"
    redirect_to @client, alert: "Erro inesperado ao atualizar histórico."
  end

  def destroy
    # ✅ OTIMIZADO: Remoção segura com limpeza de cache
    ActiveRecord::Base.transaction do
      # ✅ Remover imagens em background para não travar
      RemoveHistoryImagesJob.perform_later(@client_history.images.map(&:key)) if @client_history.images.any?

      @client_history.destroy!
      expire_client_caches
    end

    redirect_to @client, notice: "Entrada de histórico removida com sucesso!"

  rescue => e
    Rails.logger.error "Error destroying client history: #{e.message}"
    redirect_to @client, alert: "Erro ao remover histórico."
  end

  # ✅ NOVO: Endpoint para busca AJAX de históricos
  def search
    term = params[:q].to_s.strip.downcase

    histories = @client.client_histories
                      .includes(:user, images_attachments: :blob)
                      .where("LOWER(description) LIKE ? OR LOWER(action) LIKE ?", "%#{term}%", "%#{term}%")
                      .order(created_at: :desc)
                      .limit(10)

    render json: {
      histories: histories.map do |history|
        {
          id: history.id,
          action: history.action,
          description: history.description,
          created_at: history.created_at.strftime("%d/%m/%Y %H:%M"),
          images_count: history.images.count,
          user_name: history.user&.name
        }
      end
    }
  end

  # ✅ NOVO: Bulk operations
  def bulk_destroy
    history_ids = params[:history_ids].to_a.map(&:to_i)

    ActiveRecord::Base.transaction do
      histories = @client.client_histories.where(id: history_ids)

      # ✅ Coletar todas as imagens para remoção em background
      all_image_keys = histories.map { |h| h.images.map(&:key) }.flatten

      histories.destroy_all

      # ✅ Remover imagens em background
      RemoveHistoryImagesJob.perform_later(all_image_keys) if all_image_keys.any?
    end

    expire_client_caches
    redirect_to @client, notice: "#{history_ids.count} entradas de histórico removidas com sucesso!"

  rescue => e
    Rails.logger.error "Error in bulk destroy: #{e.message}"
    redirect_to @client, alert: "Erro ao remover históricos selecionados."
  end

  private

  def set_client
    # ✅ OTIMIZADO: Cache do cliente com estatísticas
    @client = Rails.cache.fetch("user_#{current_user.id}_client_#{params[:client_id]}", expires_in: 5.minutes) do
      current_user.clients
                  .includes(
                    client_histories: [ :user, images_attachments: :blob ],
                    photos_attachments: :blob
                  )
                  .find(params[:client_id])
    end

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Client not found: #{params[:client_id]} for user: #{current_user.id}"
    redirect_to clients_path, alert: "Cliente não encontrado ou você não tem permissão."
  end

  def set_client_history
    # ✅ OTIMIZADO: Usar includes para carregar imagens
    @client_history = @client.client_histories
                            .includes(:user, images_attachments: :blob)
                            .find(params[:id])

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Client history not found: #{params[:id]} for client: #{@client.id}"
    redirect_to @client, alert: "Entrada de histórico não encontrada."
  end

  def client_history_params
    params.require(:client_history).permit(:action, :description, :metadata, images: [])
  end

  # ✅ NOVOS MÉTODOS DE OTIMIZAÇÃO

  def calculate_history_stats
    {
      total_entries: @client.client_histories.count,
      entries_this_month: @client.client_histories.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count,
      total_images: @client.client_histories.joins(:images_attachments).count,
      most_recent: @client.client_histories.maximum(:created_at),
      actions_summary: @client.client_histories.group(:action).count
    }
  end

  def load_client_data_for_show
    # ✅ Carregar dados necessários para renderizar clients/show
    @client_histories = @client.client_histories
                              .includes(:user, images_attachments: :blob)
                              .order(created_at: :desc)

    @new_client_history = @client.client_histories.build
    @editing_history_id = params[:id]&.to_i
  end

  def should_update_last_contact?
    # ✅ Só atualizar se for uma ação relevante
    %w[consulta acompanhamento avaliacao contato].include?(@client_history.action.to_s.downcase)
  end

  def expire_client_caches
    Rails.cache.delete("user_#{current_user.id}_client_#{@client.id}")
    Rails.cache.delete("client_#{@client.id}_history_stats")
    Rails.cache.delete("client_#{@client.id}_stats")
  end
end
