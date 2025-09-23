# app/controllers/clients_controller.rb

class ClientsController < ApplicationController
  include TailadminLayout
  before_action :set_client, only: [ :show, :edit, :update, :destroy, :add_photos, :remove_photo, :replace_photo, :download_comparison ]

  def index
    @clients = Client.all
  end

  def show
    @client_histories = @client.client_histories.order(created_at: :desc)
    @new_client_history = @client.client_histories.build
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client, notice: "Cliente foi criado com sucesso."
    else
      render :new
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
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone_number, :sex, :age, :height, :start_date, :end_date, :paid_amount, :plan_type, :status, :note, photos: [])
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
end
