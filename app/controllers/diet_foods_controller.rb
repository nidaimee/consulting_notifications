class DietFoodsController < ApplicationController
  include TailadminLayout
  before_action :authenticate_user!
  before_action :set_client_and_diet
  before_action :set_diet_food, only: [ :show, :edit, :update, :destroy, :move_up, :move_down ]

  def index
    # ✅ OTIMIZADO: Lista com includes e ordenação
    @diet_foods = @diet.diet_foods
                       .includes(:food)
                       .order(:position, :created_at)

    # ✅ Cache dos totais da dieta
    @diet_totals = Rails.cache.fetch("diet_#{@diet.id}_totals", expires_in: 5.minutes) do
      calculate_diet_totals
    end
  end

  def show
    # ✅ OTIMIZADO: Já carregado com includes no set_diet_food
  end

  def new
    @diet_food = @diet.diet_foods.build
    @available_foods = Rails.cache.fetch("user_#{current_user.id}_foods_simple", expires_in: 10.minutes) do
      current_user.foods.select(:id, :name, :calories_per_100g, :protein_per_100g, :carbs_per_100g, :fat_per_100g)
                        .order(:name)
                        .to_a
    end
  end

 def create
    Rails.logger.info "DietFoods#create params: #{params[:diet_food].inspect}"

    raw_fq = params.dig(:diet_food, :food_quantity_id).to_s
    normalized_fq_id = if raw_fq.blank? || %w[g gram grams].include?(raw_fq.downcase)
                        nil
    else
                        raw_fq.to_i
    end

    fq = normalized_fq_id ? FoodQuantity.find_by(id: normalized_fq_id) : nil
    food_id = params.dig(:diet_food, :food_id)
    raw_quantity = params.dig(:diet_food, :quantity).to_f

    if fq
      quantity_units = raw_quantity
      quantity_grams = quantity_units * fq.grams.to_f
      attrs = {
        food_id: food_id,
        food_quantity_id: fq.id,
        quantity: quantity_units,
        quantity_grams: quantity_grams
      }
    else
      # interpretar como gramas
      attrs = {
        food_id: food_id,
        food_quantity_id: nil,
        quantity: 1,
        quantity_grams: raw_quantity
      }
    end

    @diet_food = @diet.diet_foods.build(attrs)
    @diet_food.position = (@diet.diet_foods.maximum(:position) || 0) + 1

    respond_to do |format|
      if @diet_food.save
        @diet.reload
        totals = {
          protein: @diet.diet_foods.sum { |df| df.protein.to_f }.round(1),
          carbs:   @diet.diet_foods.sum { |df| df.carbs.to_f }.round(1),
          fat:     @diet.diet_foods.sum { |df| df.fat.to_f }.round(1),
          calories: @diet.diet_foods.sum { |df| df.calories.to_f }.round(1)
        }

        row_html = render_to_string(partial: "diet_foods/row", locals: { diet_food: @diet_food }, formats: [ :html ])
        format.json { render json: { row_html: row_html, totals: totals }, status: :created }
        format.html { redirect_to client_diet_path(@client, @diet), notice: "Alimento adicionado." }
      else
        format.json { render json: { errors: @diet_food.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_to client_diet_path(@client, @diet), alert: "Erro ao adicionar: #{@diet_food.errors.full_messages.join(', ')}" }
      end
    end
  end

  def edit
    # ✅ OTIMIZADO: Dados já carregados
  end

  def update
    @diet_food = DietFood.find(params[:id])
    # Atualiza os atributos permitidos
    if @diet_food.update(diet_food_params)
      # Calcule os gramas após atualizar
      if @diet_food.food_quantity.present? && @diet_food.quantity.present?
        @diet_food.quantity_grams = @diet_food.quantity * @diet_food.food_quantity.grams
        @diet_food.save
      end

      expire_diet_caches

      respond_to do |format|
        format.html {
          redirect_to client_diet_path(@client, @diet),
                    notice: "Quantidade atualizada com sucesso!"
        }
        format.json {
          nutrition = Rails.cache.fetch("diet_food_#{@diet_food.id}_nutrition", expires_in: 1.hour) do
            calculate_diet_food_nutrition(@diet_food)
          end

          render json: {
            success: true,
            message: "Quantidade atualizada com sucesso!",
            nutrition: nutrition,
            diet_totals: calculate_diet_totals
          }
        }
      end
    else
      Rails.logger.error "DietFood update failed: #{@diet_food.errors.full_messages}"

      respond_to do |format|
        format.html {
          redirect_to client_diet_path(@client, @diet),
                    alert: "Erro ao atualizar quantidade: #{@diet_food.errors.full_messages.join(', ')}"
        }
        format.json {
          render json: {
            success: false,
            message: "Erro ao atualizar quantidade: #{@diet_food.errors.full_messages.join(', ')}"
          }, status: :unprocessable_entity
        }
      end
    end

  rescue => e
    Rails.logger.error "Error in DietFoodsController#update: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro inesperado ao atualizar alimento."
  end

  def destroy
    food_name = @diet_food.food.name

    ActiveRecord::Base.transaction do
      @diet_food.destroy!
      expire_diet_caches

      # ✅ OTIMIZADO: Reordenar posições restantes
      reorder_positions_after_deletion(@diet_food.position)
    end

    redirect_to client_diet_path(@client, @diet), notice: "#{food_name} removido da dieta!"

  rescue => e
    Rails.logger.error "Error destroying diet_food: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro ao remover alimento."
  end

  # ✅ OTIMIZADO: Movimentação via posições
  def move_up
    move_to_position(@diet_food.position - 1)
  end

  def move_down
    move_to_position(@diet_food.position + 1)
  end

  # ✅ NOVO: Reordenação via AJAX
  def reorder
    order_data = params[:order] || []

    return render json: { success: false, message: "Nenhum dado para reordenar" } if order_data.empty?

    ActiveRecord::Base.transaction do
      order_data.each_with_index do |item, index|
        diet_food = @diet.diet_foods.find(item[:id])
        diet_food.update!(position: index + 1)
      end
    end

    expire_diet_caches
    render json: { success: true, message: "Ordem atualizada com sucesso!" }

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "DietFood not found for reordering: #{e.message}"
    render json: { success: false, message: "Item não encontrado." }, status: :not_found
  rescue => e
    Rails.logger.error "Error reordering diet foods: #{e.message}"
    render json: { success: false, message: "Erro ao reordenar itens." }, status: :internal_server_error
  end

  # ✅ NOVO: Duplicar alimento
  def duplicate
    ActiveRecord::Base.transaction do
      duplicated = @diet_food.dup
      duplicated.position = next_position
      duplicated.save!

      expire_diet_caches
    end

    redirect_to client_diet_path(@client, @diet),
               notice: "#{@diet_food.food.name} duplicado com sucesso!"

  rescue => e
    Rails.logger.error "Error duplicating diet_food: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro ao duplicar alimento."
  end

  # ✅ NOVO: Bulk operations
  def bulk_destroy
    diet_food_ids = params[:diet_food_ids].to_a.map(&:to_i)

    ActiveRecord::Base.transaction do
      destroyed_count = @diet.diet_foods.where(id: diet_food_ids).destroy_all.count
      expire_diet_caches

      redirect_to client_diet_path(@client, @diet),
                 notice: "#{destroyed_count} alimentos removidos da dieta!"
    end

  rescue => e
    Rails.logger.error "Error in bulk destroy: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro ao remover alimentos selecionados."
  end

  # ✅ NOVO: Quick add (AJAX)
  def quick_add
    food = current_user.foods.find(params[:food_id])
    quantity = params[:quantity].to_f

    ActiveRecord::Base.transaction do
      diet_food = @diet.diet_foods.create!(
        food: food,
        quantity_grams: quantity,
        position: next_position
      )

      expire_diet_caches

      nutrition = calculate_diet_food_nutrition(diet_food)

      render json: {
        success: true,
        message: "#{food.name} adicionado com sucesso!",
        diet_food: {
          id: diet_food.id,
          name: food.name,
          quantity: quantity,
          nutrition: nutrition
        },
        diet_totals: calculate_diet_totals
      }
    end

  rescue ActiveRecord::RecordInvalid => e
    render json: { success: false, message: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Alimento não encontrado." }, status: :not_found
  rescue => e
    Rails.logger.error "Error in quick_add: #{e.message}"
    render json: { success: false, message: "Erro inesperado." }, status: :internal_server_error
  end

  private

  def set_client_and_diet
    # ✅ OTIMIZADO: Cache e includes estratégicos
    @client = Rails.cache.fetch("user_#{current_user.id}_client_#{params[:client_id]}", expires_in: 5.minutes) do
      current_user.clients.includes(:diets).find(params[:client_id])
    end

    @diet = @client.diets.includes(diet_foods: :food).find(params[:diet_id])

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Client or Diet not found: #{e.message}"
    redirect_to clients_path, alert: "Cliente ou dieta não encontrada."
  end

  def set_diet_food
    @diet_food = @diet.diet_foods.includes(:food).find(params[:id])

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "DietFood not found: #{params[:id]}"
    redirect_to client_diet_path(@client, @diet), alert: "Item da dieta não encontrado."
  end

  def diet_food_params
    params.require(:diet_food).permit(:quantity_grams, :calories, :protein, :carbs, :fat, :notes, :food_quantity_id, :quantity)
  end


  def calculate_diet_food_nutrition(diet_food)
    return {} unless diet_food.food && diet_food.quantity_grams

    food = diet_food.food
    quantity_ratio = diet_food.quantity_grams / 100.0

    {
      protein: (food.protein_per_100g * quantity_ratio).round(1),
      carbs: (food.carbs_per_100g * quantity_ratio).round(1),
      fat: (food.fat_per_100g * quantity_ratio).round(1),
      calories: (food.calories_per_100g * quantity_ratio).round(1)
    }
  end

  def calculate_diet_totals
    @diet.diet_foods.includes(:food).sum do |df|
      next 0 unless df.food && df.quantity_grams

      ratio = df.quantity_grams / 100.0
      {
        calories: (df.food.calories_per_100g * ratio).round(1),
        protein: (df.food.protein_per_100g * ratio).round(1),
        carbs: (df.food.carbs_per_100g * ratio).round(1),
        fat: (df.food.fat_per_100g * ratio).round(1)
      }
    end
  end

  def next_position
    (@diet.diet_foods.maximum(:position) || 0) + 1
  end

  def move_to_position(new_position)
    return if new_position < 1

    max_position = @diet.diet_foods.maximum(:position) || 1
    return if new_position > max_position

    ActiveRecord::Base.transaction do
      if new_position < @diet_food.position
        # Movendo para cima
        @diet.diet_foods.where("position >= ? AND position < ?", new_position, @diet_food.position)
             .update_all("position = position + 1")
      else
        # Movendo para baixo
        @diet.diet_foods.where("position > ? AND position <= ?", @diet_food.position, new_position)
             .update_all("position = position - 1")
      end

      @diet_food.update!(position: new_position)
      expire_diet_caches
    end

    redirect_to client_diet_path(@client, @diet), notice: "Posição do alimento atualizada!"

  rescue => e
    Rails.logger.error "Error moving diet_food: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro ao mover alimento."
  end

  def reorder_positions_after_deletion(deleted_position)
    @diet.diet_foods.where("position > ?", deleted_position)
         .update_all("position = position - 1")
  end

  def expire_diet_caches
    Rails.cache.delete("diet_#{@diet.id}_totals")
    Rails.cache.delete("client_#{@client.id}_daily_totals")
    Rails.cache.delete("user_#{current_user.id}_client_#{@client.id}")

    # Limpar cache de nutrition de todos os diet_foods desta dieta
    @diet.diet_foods.pluck(:id).each do |diet_food_id|
      Rails.cache.delete("diet_food_#{diet_food_id}_nutrition")
    end
  end
end
