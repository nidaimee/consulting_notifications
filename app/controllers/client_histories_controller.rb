class ClientHistoriesController < ApplicationController
  include TailadminLayout
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_history, only: [ :destroy ]

  def create
    @client_history = @client.client_histories.build(client_history_params)

    if @client_history.save
      redirect_to @client, notice: "Entrada de histórico adicionada com sucesso!"
    else
      redirect_to @client, alert: "Erro ao adicionar entrada: #{@client_history.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @client_history.destroy
    redirect_to @client, alert: "Entrada de histórico removida com sucesso!"
  end

  def edit
  end

  def update
    @client = Client.find(params[:client_id])
    @history = @client.client_histories.find(params[:id])
    if @history.update(history_params)
      redirect_to client_path(@client), notice: "Histórico atualizado com sucesso."
    else
      @client_histories = @client.client_histories.order(created_at: :desc)
      render "clients/show"
    end
  end

private

def history_params
  params.require(:client_history).permit(:description, images: [])
end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_client_history
    @client_history = @client.client_histories.find(params[:id])
  end

  def client_history_params
    params.require(:client_history).permit(:action, :description, :metadata, images: [])
  end
end
