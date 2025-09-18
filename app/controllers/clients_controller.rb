# app/controllers/clients_controller.rb

class ClientsController < ApplicationController
  before_action :authenticate_user! # Se você usar Devise
  before_action :set_client, only: [ :show, :edit, :update, :destroy, :diet_pdf ]

  def index
    @clients = current_user.clients # Assumindo que há relação User has_many :clients

    # Busca por texto (nome, email, telefone)
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @clients = @clients.where(
        "LOWER(name) LIKE :search OR LOWER(email) LIKE :search OR phone_number LIKE :search OR LOWER(note) LIKE :search",
        search: search_term
      )
    end

    # Filtro por status
    if params[:status].present?
      @clients = @clients.where(status: params[:status])
    end

    # Filtro por período (baseado em start_date/end_date)
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

    # Filtro por faixa de valor pago
    if params[:min_paid_amount].present?
      @clients = @clients.where("paid_amount >= ?", params[:min_paid_amount].to_f)
    end

    if params[:max_paid_amount].present?
      @clients = @clients.where("paid_amount <= ?", params[:max_paid_amount].to_f)
    end

    # Filtro por data de cadastro
    if params[:created_after].present?
      @clients = @clients.where("created_at >= ?", params[:created_after])
    end

    if params[:created_before].present?
      @clients = @clients.where("created_at <= ?", params[:created_before])
    end

    # Filtro por último contato
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
      @clients = @clients.order(:name) # Ordenação padrão
    end

    # Paginação (se estiver usando Kaminari)
    @clients = @clients.page(params[:page]).per(12) if defined?(Kaminari)

    respond_to do |format|
      format.html
      format.json { render json: @clients }
      format.csv { send_data generate_csv(@clients), filename: "clients-#{Date.current}.csv" }
    end
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
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      # Atualizar last_contacted_at se houver interação
      @client.touch(:last_contacted_at) if params[:mark_as_contacted]

      redirect_to @client, notice: "Cliente atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: "Cliente removido com sucesso."
  end
# app/controllers/clients_controller.rb

def diet_pdf
  @diets = @client.diets
                .includes(diet_foods: [ :food, { food_substitutions: :substitute_food } ])
                .order(:meal_type)
  @daily_totals = calculate_daily_totals(@diets)

  # Determinar o tema baseado no parâmetro
  theme = params[:theme] || "light"

  # Determinar o layout baseado no tema
  layout_name = case theme
  when "dark"
                  "pdf_dark"
  when "professional"
                  "pdf_professional"
  else
                  "pdf" # tema claro padrão
  end

  respond_to do |format|
    format.html do
      # Para preview no navegador, usar o layout escolhido
      render "diet_pdf", layout: layout_name
    end

    format.pdf do
      html = render_to_string(
        template: "clients/diet_pdf",
        layout: layout_name,
        formats: [ :html ],
        locals: {
          theme: theme,
          include_substitutions: params[:include_substitutions] != "0",
          include_notes: params[:include_notes] != "0"
        }
      )

      pdf = WickedPdf.new.pdf_from_string(
        html,
          page_size: "A4",
          margin: { top: 0, bottom: 0, left: 0, right: 0 }, # sem margem
          encoding: "UTF-8",
          background: true,
          print_media_type: true
        )

      send_data pdf,
                filename: "dieta_#{@client.name.parameterize}_#{theme}.pdf",
                type: "application/pdf",
                disposition: params[:preview] ? "inline" : "attachment"
    end
  end
end
  # Ações customizadas
  def search_suggestions
    term = params[:term]
    suggestions = current_user.clients
                              .where("LOWER(name) LIKE :search OR LOWER(email) LIKE :search",
                                     search: "%#{term.downcase}%")
                              .limit(10)
                              .pluck(:name, :email)
                              .map { |name, email| { name: name, email: email } }

    render json: suggestions
  end

  def bulk_actions
    client_ids = params[:client_ids]
    clients = current_user.clients.where(id: client_ids)

    case params[:bulk_action]
    when "activate"
      clients.update_all(status: "active")
      redirect_to clients_path, notice: "Clientes ativados com sucesso."
    when "deactivate"
      clients.update_all(status: "inactive")
      redirect_to clients_path, notice: "Clientes desativados com sucesso."
    when "delete"
      clients.destroy_all
      redirect_to clients_path, notice: "Clientes removidos com sucesso."
    when "export"
      send_data generate_csv(clients), filename: "clients-export-#{Date.current}.csv"
    when "mark_contacted"
      clients.update_all(last_contacted_at: Time.current)
      redirect_to clients_path, notice: "Clientes marcados como contatados."
    else
      redirect_to clients_path, alert: "Ação não reconhecida."
    end
  end

  private
  def calculate_daily_totals(diets)
    return { calories: 0, protein: 0, carbs: 0, fat: 0 } if diets.empty?

    {
      calories: diets.sum(&:total_calories),
      protein: diets.sum(&:total_protein),
      carbs: diets.sum(&:total_carbs),
      fat: diets.sum(&:total_fat)
    }
  end
  def set_client
    Rails.logger.info "Procurando cliente com ID: #{params[:id]}"
    @client = current_user.clients.find(params[:id])
    Rails.logger.info "Cliente encontrado: #{@client.name}" if @client
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Cliente não encontrado com ID: #{params[:id]}"
    redirect_to clients_path, alert: "Cliente não encontrado."
  end

  def client_params
    params.require(:client).permit(
      :name, :email, :phone_number, :start_date, :end_date,
      :paid_amount, :note, :status, :last_contacted_at, :plan_type
    )
  end

  def generate_csv(clients)
    require "csv"

    CSV.generate(headers: true) do |csv|
      csv << [ "Nome", "Email", "Telefone", "Status", "Valor Pago", "Início", "Fim", "Último Contato", "Observações" ]

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
          client.note,
          client.plan_type&.capitalize
        ]
      end
    end
  end
end
