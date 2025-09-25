# app/controllers/clients_controller.rb

class ClientsController < ApplicationController
  include TailadminLayout
  before_action :set_client, only: [ :show, :edit, :update, :destroy, :add_photos, :remove_photo, :replace_photo, :download_comparison ]

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
    @editing_history_id = params[:edit_history_id]&.to_i
    @client_histories = @client.client_histories.order(created_at: :desc)
    @new_client_history = @client.client_histories.build
  end

  def new
    @client = Client.new
  end

  def create
    @client = current_user.clients.build(client_params)

    # DEBUG: Vamos adicionar logs para entender o problema
    Rails.logger.debug "Current user: #{current_user.inspect}"
    Rails.logger.debug "Client params: #{client_params.inspect}"
    Rails.logger.debug "Client user_id before save: #{@client.user_id}"

    if @client.save
      redirect_to @client, notice: "Cliente criado com sucesso."
    else
      Rails.logger.error "Client validation errors: #{@client.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Cliente foi atualizado com sucesso."
    else
      render :edit
    end
  end
  def update_note
  @client = Client.find(params[:id])
  if @client.update(note: params[:client][:note])
    redirect_to client_diets_path(@client), notice: "Observação atualizada com sucesso!"
  else
    redirect_to client_diets_path(@client), alert: "Erro ao atualizar observação."
  end
end
  def destroy
    @client.destroy
    redirect_to clients_url, notice: "Cliente foi removido com sucesso."
  end

  def add_photos
    if params[:client][:photos].present?
      params[:client][:photos].each do |photo|
        @client.photos.attach(photo)
      end
      redirect_to @client, notice: "Fotos adicionadas com sucesso."
    else
      redirect_to @client, alert: "Nenhuma foto foi selecionada."
    end
  end
def diet_pdf
    client_id = params[:client_id] || params[:id]
    @client = Client.find(client_id)
    @diets = @client.diets
      .includes(diet_foods: [ :food, { food_substitutions: :substitute_food } ])
      .order(:meal_type)

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
  def serve_image
    blob_id = params[:blob_id]

    begin
      blob = ActiveStorage::Blob.find_signed(blob_id)

      # Servir a imagem diretamente com headers apropriados
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
      # Remover foto do histórico
      history = @client.client_histories.find(history_id)
      photo = history.images.find(photo_id)
      photo.purge
      redirect_to @client, alert: "Foto do histórico removida com sucesso."
    else
      # Remover foto principal do cliente
      photo = @client.photos.find(photo_id)
      photo.purge
      redirect_to @client, alert: "Foto removida com sucesso."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to @client, alert: "Foto não encontrada."
  end

  def replace_photo
    old_photo = @client.photos.find(params[:id])

    if params[:photo].present?
      old_photo.purge
      @client.photos.attach(params[:photo])
      redirect_to @client, notice: "Foto substituída com sucesso."
    else
      redirect_to @client, alert: "Nenhuma foto foi selecionada."
    end
  end

  def download_comparison
    photo1_id = params[:photo1_id]
    photo2_id = params[:photo2_id]

    # Buscar as fotos (podem ser de client.photos ou client_histories.images)
    photo1 = find_photo_by_signed_id(photo1_id)
    photo2 = find_photo_by_signed_id(photo2_id)

    unless photo1 && photo2
      redirect_to @client, alert: "Fotos não encontradas para comparação"
      return
    end

    begin
      # Gerar comparação usando mini_magick
      comparison_image = generate_comparison_image(photo1, photo2)

      send_data comparison_image.to_blob,
        type: "image/png",
        disposition: "attachment",
        filename: "comparacao-evolucao-#{@client.name.parameterize}-#{Date.current.strftime('%Y-%m-%d')}.png"
    rescue => e
      Rails.logger.error "Erro ao gerar comparação: #{e.message}"
      redirect_to @client, alert: "Erro ao gerar comparação. Tente novamente."
    end
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

  def find_photo_by_signed_id(signed_id)
    return nil unless signed_id.present?

    begin
      # Tentar encontrar pela signed_id do Active Storage
      blob = ActiveStorage::Blob.find_signed(signed_id)
      return blob if blob
    rescue ActiveRecord::RecordNotFound
      # Se não encontrar, tentar outras abordagens
    end

    # Buscar nas fotos principais do cliente
    @client.photos.each do |photo|
      return photo if photo.signed_id == signed_id || photo.key.include?(signed_id)
    end

    # Buscar nas fotos do histórico
    @client.client_histories.each do |history|
      history.images.each do |image|
        return image if image.signed_id == signed_id || image.key.include?(signed_id)
      end
    end

    nil
  end

  def generate_comparison_image(photo1, photo2)
    require "mini_magick"

    # Baixar e processar as imagens
    img1_data = photo1.download
    img2_data = photo2.download

    img1 = MiniMagick::Image.read(img1_data)
    img2 = MiniMagick::Image.read(img2_data)

    # Redimensionar mantendo proporção (máximo 400x400)
    img1.resize "400x400>"
    img2.resize "400x400>"

    # Configurações do canvas
    canvas_width = 1200
    canvas_height = 800
    margin = 100

    # Criar canvas branco
    canvas = MiniMagick::Image.open("canvas:white") do |c|
      c.size "#{canvas_width}x#{canvas_height}"
    end

    # Adicionar título
    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 28
      c.weight "bold"
      c.fill "black"
      c.gravity "north"
      c.annotate "+0+30", "Comparação de Evolução - #{@client.name}"
    end

    # Adicionar data
    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 16
      c.fill "gray"
      c.gravity "north"
      c.annotate "+0+70", "Gerado em: #{Date.current.strftime('%d/%m/%Y')}"
    end

    # Calcular posições das imagens
    available_width = canvas_width - (margin * 2)
    img_space = available_width / 2

    img1_x = margin + (img_space / 2) - (img1.width / 2)
    img2_x = margin + img_space + (img_space / 2) - (img2.width / 2)
    img_y = 120

    # Adicionar primeira imagem
    canvas = canvas.composite(img1) do |c|
      c.geometry "+#{img1_x}+#{img_y}"
    end

    # Adicionar segunda imagem
    canvas = canvas.composite(img2) do |c|
      c.geometry "+#{img2_x}+#{img_y}"
    end

    # Adicionar labels
    label1_data = get_photo_label(photo1)
    label2_data = get_photo_label(photo2)

    label_y = img_y + 450

    # Label da primeira imagem
    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 20
      c.weight "bold"
      c.fill "black"
      c.gravity "center"
      c.annotate "+#{(img1_x + img1.width/2) - canvas_width/2}+#{label_y - canvas_height/2}", label1_data[:type]
    end

    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 16
      c.fill "gray"
      c.gravity "center"
      c.annotate "+#{(img1_x + img1.width/2) - canvas_width/2}+#{label_y + 25 - canvas_height/2}", label1_data[:date]
    end

    # Label da segunda imagem
    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 20
      c.weight "bold"
      c.fill "black"
      c.gravity "center"
      c.annotate "+#{(img2_x + img2.width/2) - canvas_width/2}+#{label_y - canvas_height/2}", label2_data[:type]
    end

    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 16
      c.fill "gray"
      c.gravity "center"
      c.annotate "+#{(img2_x + img2.width/2) - canvas_width/2}+#{label_y + 25 - canvas_height/2}", label2_data[:date]
    end

    # Adicionar linha separadora
    separator = MiniMagick::Image.open("canvas:lightgray") do |c|
      c.size "2x350"
    end

    canvas = canvas.composite(separator) do |c|
      c.geometry "+#{canvas_width/2 - 1}+#{img_y}"
    end

    # Adicionar watermark
    canvas.combine_options do |c|
      c.font "Arial"
      c.pointsize 12
      c.fill "lightgray"
      c.gravity "southeast"
      c.annotate "+20+20", "Sistema de Consultoria Nutricional"
    end

    canvas.format "png"
    canvas
  end

  def get_photo_label(photo)
    # Determinar se é foto inicial ou do histórico
    if @client.photos.any? { |p| p.key == photo.key }
      {
        type: "Inicial",
        date: @client.start_date.strftime("%d/%m/%Y")
      }
    else
      # Buscar em qual histórico está
      history = @client.client_histories.find do |h|
        h.images.any? { |i| i.key == photo.key }
      end

      if history
        {
          date: history.created_at.strftime("%d/%m/%Y")
        }
      else
        {
          type: "Foto",
          date: Date.current.strftime("%d/%m/%Y")
        }
      end
    end
  end
  def get_history_type(history)
    case history.action&.downcase
    when "medicao_peso"
      "Medição de Peso"
    when "acompanhamento"
      "Acompanhamento"
    when "avaliacao"
      "Avaliação"
    else
      history.action&.humanize || "Evolução"
    end
  end
  def generate_csv(clients)
    require "csv"

    CSV.generate(headers: true) do |csv|
      csv << [ "Nome", "Email", "Telefone", "Status", "Valor Pago", "Início", "Fim", "Último Contato", "Plano", "Observações" ]

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
