class ClientsController < ApplicationController
  before_action :set_client, only: [ :show, :edit, :update, :destroy ]

  def index
    @clients = current_user.clients.order(:name)
  end

  def show
    @diets = @client.diets.includes(:foods)
    @total_diets = @diets.count
    @total_calories = @diets.sum(&:total_calories)
  end

  def new
    @client = current_user.clients.build
  end

  def create
    @client = current_user.clients.build(client_params)

    if @client.save
      redirect_to @client, notice: "Cliente criado com sucesso."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Cliente atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: "Cliente removido com sucesso."
  end

  private

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :phone_number, :start_date, :end_date, :paid_amount, :note, :status)
  end
end
