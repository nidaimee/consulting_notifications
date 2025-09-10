# ===============================================
# CORRIGIR ERRO @client NIL NO PDF
# ===============================================

# 1. VERIFICAR O CLIENTS CONTROLLER COMPLETO
# app/controllers/clients_controller.rb

class ClientsController < ApplicationController
  before_action :set_client, only: [ :show, :edit, :update, :destroy, :diet_pdf ]

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

  # PDF da dieta completa do cliente
  def diet_pdf
  @diets = @client.diets
                .includes(diet_foods: [ :food, { food_substitutions: :substitute_food } ])
                .order(:meal_type)
  @daily_totals = calculate_daily_totals(@diets)

    respond_to do |format|
      format.html do
        render "diet_pdf"
      end

      format.pdf do
        html = render_to_string(
          template: "clients/diet_pdf",
          layout: "pdf",
          formats: [ :html ]
        )

        pdf = WickedPdf.new.pdf_from_string(html)
        send_data pdf,
                  filename: "dieta_#{@client.name.parameterize}.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
    end
  end

  private

  def set_client
    Rails.logger.info "Procurando cliente com ID: #{params[:id]}"
    @client = current_user.clients.find(params[:id])
    Rails.logger.info "Cliente encontrado: #{@client.name}" if @client
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Cliente não encontrado com ID: #{params[:id]}"
    redirect_to clients_path, alert: "Cliente não encontrado."
  end

  def client_params
    params.require(:client).permit(:name, :phone, :start_date, :end_date, :paid_amount, :notes, :status)
  end

  def calculate_daily_totals(diets)
    return { calories: 0, protein: 0, carbs: 0, fat: 0 } if diets.empty?

    {
      calories: diets.sum(&:total_calories),
      protein: diets.sum(&:total_protein),
      carbs: diets.sum(&:total_carbs),
      fat: diets.sum(&:total_fat)
    }
  end
end
