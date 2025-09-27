class ClientsController < ApplicationController
  include TailadminLayout
  before_action :set_client, only: [ :show, :edit, :update, :destroy, :add_photos, :remove_photo, :replace_photo, :download_comparison, :diet_pdf, :serve_image, :update_note ]

  def index
    @clients = current_user.clients

    # TODOS os filtros existentes
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @clients = @clients.where(
        "LOWER(name) LIKE :search OR LOWER(email) LIKE :search OR phone_number LIKE :search OR LOWER(note) LIKE :search",
        search: search_term
      )
    end

    if params[:status].present?
      @clients = @clients.where(status: params[:status])
    end

    case params[:period]
    when "this_month"
      @clients = @clients.where(
        "start_date <= ? AND end_date >= ?",
        Date.current.end_of_month,
        Date.current.beginning_of_month
      )
    when "last_3_months"
      @clients = @clients.where(
        "start_date >= ? OR end_date >= ?",
        3.months.ago,
        3.months.ago
      )
    when "this_year"
      @clients = @clients.where(
        "start_date <= ? AND end_date >= ?",
        Date.current.end_of_year,
        Date.current.beginning_of_year
      )
    end

    if params[:min_paid_amount].present?
      @clients = @clients.where("paid_amount >= ?", params[:min_paid_amount].to_f)
    end

    if params[:max_paid_amount].present?
      @clients = @clients.where("paid_amount <= ?", params[:max_paid_amount].to_f)
    end

    if params[:created_after].present?
      @clients = @clients.where("created_at >= ?", params[:created_after])
    end

    if params[:created_before].present?
      @clients = @clients.where("created_at <= ?", params[:created_before])
    end

    if params[:last_contact_days].present?
      days_ago = params[:last_contact_days].to_i.days.ago
      @clients = @clients.where("last_contacted_at >= ?", days_ago)
    end

    # Ordenação
    case params[:sort_by]
    when "name"
      @clients = @clients.order(:name)
    when "created_at_desc"
      @clients = @clients.order(created_at: :desc)
    when "created_at_asc"
      @clients = @clients.order(created_at: :asc)
    when "paid_amount_desc"
      @clients = @clients.order(paid_amount: :desc)
    when "paid_amount_asc"
      @clients = @clients.order(paid_amount: :asc)
    when "last_contacted_at_desc"
      @clients = @clients.order(last_contacted_at: :desc)
    when "end_date_asc"
      @clients = @clients.order(end_date: :asc)
    else
      @clients = @clients.order(:name)
    end

    # ✅ PAGINAÇÃO SEGURA
    page = [ params[:page].to_i, 1 ].max
    per_page = 20

    if defined?(Kaminari)
      @clients = @clients.page(page).per(per_page)
    else
      # Contagem total ANTES de aplicar limit/offset
      @total_count = @clients.count
      @total_pages = (@total_count / per_page.to_f).ceil
      @current_page = [ page, @total_pages ].min if @total_pages > 0
      @current_page ||= 1

      # OFFSET sempre >= 0
      offset = (@current_page - 1) * per_page
      @clients = @clients.limit(per_page).offset([ offset, 0 ].max)

      @next_page = @current_page + 1 if @current_page < @total_pages
      @prev_page = @current_page - 1 if @current_page > 1
    end

    respond_to do |format|
      format.html
      format.json { render json: @clients }
      format.csv { send_data generate_csv(@clients), filename: "clients-#{Date.current}.csv" }
    end
  end

  def show
    @editing_history_id = params[:edit_history_id]&.to_i

    # ✅ OTIMIZADO: Uma única query com todos os includes necessários
    @client_histories = @client.client_histories
                              .includes(images_attachments: :blob)
                              .order(created_at: :desc)
                              .limit(20)

    @new_client_history = @client.client_histories.build

    # ✅ Cache dos totais e estatísticas do cliente
    @client_stats = Rails.cache.fetch("client_#{@client.id}_stats", expires_in: 5.minutes) do
      calculate_client_detailed_stats
    end

    # ✅ Pre-carregar dados para o JavaScript
    @preloaded_data = {
      client_id: @client.id,
      photos_count: @client.photos.count,
      histories_count: @client.client_histories.count,
      diets_count: @client.diets.count
    }
  end

  def new
    @client = current_user.clients.build
  end

  def create
    @client = current_user.clients.build(client_params)

    if @client.save
      # ✅ Limpar caches relacionados
      expire_client_caches(@client)

      # ✅ CORRIGIDO: Só processar se jobs existirem
      # ClientCreatedJob.perform_later(@client) if defined?(ClientCreatedJob) && @client.photos.attached?

      redirect_to @client, notice: "Cliente criado com sucesso."
    else
      Rails.logger.error "Client validation errors: #{@client.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Já otimizado com set_client
  end

  def update
    if @client.update(client_params)
      expire_client_caches(@client)
      redirect_to @client, notice: "Cliente foi atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_note
    if @client.update(note: params[:client][:note])
      expire_client_caches(@client)
      redirect_to client_diets_path(@client), notice: "Observação atualizada com sucesso!"
    else
      redirect_to client_diets_path(@client), alert: "Erro ao atualizar observação."
    end
  end

  def destroy
    client_id = @client.id
    @client.destroy

    # ✅ Limpar todos os caches relacionados
    expire_all_client_caches(client_id)

    redirect_to clients_url, notice: "Cliente foi removido com sucesso."
  end

  def add_photos
    if params[:client][:photos].present?
      # ✅ CORRIGIDO: Processamento síncrono por enquanto
      params[:client][:photos].each do |photo|
        @client.photos.attach(photo)
      end

      expire_client_caches(@client)
      redirect_to @client, notice: "Fotos adicionadas com sucesso."
    else
      redirect_to @client, alert: "Nenhuma foto foi selecionada."
    end
  end

  def diet_pdf
    # ✅ OTIMIZADO: Cache do PDF e includes estratégico
    @diets = @client.diets
                   .includes(
                     diet_foods: [
                       :food,
                       { food_substitutions: :substitute_food }
                     ]
                   )
                   .order(:position)

    # ✅ Cache dos totais para PDF
    @daily_totals = Rails.cache.fetch("client_#{@client.id}_daily_totals", expires_in: 1.hour) do
      calculate_daily_totals(@diets)
    end

    layout_name = "pdf"

    respond_to do |format|
      format.html { render "diet_pdf", layout: layout_name }

      format.pdf do
        # ✅ CORRIGIDO: Remover cache complexo por enquanto
        html = render_to_string(
          template: "clients/diet_pdf",
          layout: layout_name,
          formats: [ :html ],
          locals: {
            theme: "light",
            include_substitutions: params[:include_substitutions] != "0",
            include_notes: params[:include_notes] != "0"
          }
        )

        pdf = WickedPdf.new.pdf_from_string(
          html,
          page_size: "A4",
          margin: { top: 0, bottom: 0, left: 0, right: 0 },
          encoding: "UTF-8",
          background: true,
          print_media_type: true
        )

        send_data pdf,
          filename: "dieta_#{@client.name.parameterize}_#{Date.current.strftime('%Y%m%d')}.pdf",
          type: "application/pdf",
          disposition: params[:preview] ? "inline" : "attachment"
      end
    end
  end

  def serve_image
    blob_id = params[:blob_id]

    begin
      blob = ActiveStorage::Blob.find_signed(blob_id)

      # ✅ Headers otimizados para cache
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Cache-Control"] = "public, max-age=3600"

      send_data blob.download,
        type: blob.content_type,
        disposition: "inline"

    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end

  def remove_photo
    photo_id = params[:photo_id]
    history_id = params[:history_id]

    if history_id.present?
      history = @client.client_histories.find(history_id)
      photo = history.images.find(photo_id)
      photo.purge
      expire_client_caches(@client)
      redirect_to @client, notice: "Foto do histórico removida com sucesso."
    else
      photo = @client.photos.find(photo_id)
      photo.purge
      expire_client_caches(@client)
      redirect_to @client, notice: "Foto removida com sucesso."
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to @client, alert: "Foto não encontrada."
  end

  def replace_photo
    old_photo = @client.photos.find(params[:photo_id])

    if params[:photo].present?
      old_photo.purge
      @client.photos.attach(params[:photo])
      expire_client_caches(@client)
      redirect_to @client, notice: "Foto substituída com sucesso."
    else
      redirect_to @client, alert: "Nenhuma foto foi selecionada."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to @client, alert: "Foto não encontrada."
  end

  def download_comparison
    photo1_id = params[:photo1_id]
    photo2_id = params[:photo2_id]

    # ✅ CORRIGIDO: Processamento síncrono por enquanto
    redirect_to @client, notice: "Funcionalidade de comparação em desenvolvimento."
  end

  private

  def set_client
    client_id = params[:client_id] || params[:id]
    Rails.logger.info "Procurando cliente com ID: #{client_id}"
    @client = current_user.clients.find(client_id)
    Rails.logger.info "Cliente encontrado: #{@client.name}" if @client
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Cliente não encontrado com ID: #{client_id}"
    redirect_to clients_path, alert: "Cliente não encontrado."
  end

  def client_params
    params.require(:client).permit(
      :name, :email, :phone_number, :sex, :age, :height,
      :start_date, :end_date, :paid_amount, :plan_type,
      :status, :note, :last_contacted_at, photos: []
    )
  end

  def calculate_client_detailed_stats
    {
      total_diets: @client.diets.count,
      total_histories: @client.client_histories.count,
      total_photos: @client.photos.count,
      days_since_start: @client.start_date ? (Date.current - @client.start_date).to_i : 0,
      days_remaining: @client.end_date ? (@client.end_date - Date.current).to_i : nil,
      last_contact_days: @client.last_contacted_at ? (Date.current - @client.last_contacted_at.to_date).to_i : nil
    }
  end

  def calculate_daily_totals(diets)
    return { calories: 0, protein: 0, carbs: 0, fat: 0 } if diets.empty?

    # ✅ CORRIGIDO: Cálculo simples que funciona
    {
      calories: diets.sum(&:total_calories) || 0,
      protein: diets.sum(&:total_protein) || 0,
      carbs: diets.sum(&:total_carbs) || 0,
      fat: diets.sum(&:total_fat) || 0
    }
  end

  def generate_csv(clients)
    require "csv"

    CSV.generate(headers: true, encoding: "UTF-8") do |csv|
      csv << [
        "Nome", "Email", "Telefone", "Status", "Valor Pago",
        "Início", "Fim", "Último Contato", "Plano", "Observações"
      ]

      clients.each do |client|
        csv << [
          client.name,
          client.email,
          client.phone_number,
          client.status&.capitalize,
          "R$ #{client.paid_amount}",
          client.start_date&.strftime("%d/%m/%Y"),
          client.end_date&.strftime("%d/%m/%Y"),
          client.last_contacted_at&.strftime("%d/%m/%Y %H:%M"),
          client.plan_type&.capitalize,
          client.note
        ]
      end
    end
  end

  def expire_client_caches(client)
    Rails.cache.delete("user_#{current_user.id}_clients_stats")
    Rails.cache.delete("user_#{current_user.id}_client_#{client.id}")
    Rails.cache.delete("client_#{client.id}_stats")
    Rails.cache.delete("client_#{client.id}_daily_totals")
  end

  def expire_all_client_caches(client_id)
    Rails.cache.delete("user_#{current_user.id}_clients_stats")
    Rails.cache.delete("user_#{current_user.id}_client_#{client_id}")
    Rails.cache.delete("client_#{client_id}_stats")
    Rails.cache.delete("client_#{client_id}_daily_totals")
  end
end
