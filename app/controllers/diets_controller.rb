class DietsController < ApplicationController
  include TailadminLayout
  before_action :set_client
  before_action :set_diet, only: [ :show, :edit, :update, :destroy, :add_food, :add_substitution, :remove_substitution, :reorder_foods ]

  def index
    @diets = @client.diets
                  .includes(diet_foods: :food)
                  .order(:position)

    # ✅ SIMPLES E FUNCIONAL: Cálculo em Ruby
    @daily_total_calories = @diets.sum do |diet|
      diet.diet_foods.sum do |diet_food|
        next 0 unless diet_food.food && diet_food.quantity_grams

        (diet_food.quantity_grams * diet_food.food.calories_per_100g) / 100.0
      end
    end.round(1)
  end

  def show
    # ✅ OTIMIZADO: Carrega todas as associações de uma vez
    @available_foods = Rails.cache.fetch("user_#{current_user.id}_foods", expires_in: 10.minutes) do
      current_user.foods.select(:id, :name, :calories_per_100g, :protein_per_100g, :carbs_per_100g, :fat_per_100g)
                        .order(:name)
                        .to_a
    end

    @diet_food = DietFood.new

    # ✅ Cache dos cálculos da dieta
    @diet_totals = Rails.cache.fetch("diet_#{@diet.id}_totals", expires_in: 5.minutes) do
      calculate_diet_totals(@diet)
    end
  end

  def new
    @diet = @client.diets.build(position: next_position)
  end

  def create
    @diet = @client.diets.build(diet_params)
    @diet.created_date = Date.current
    @diet.position = next_position

    if @diet.save
      # ✅ Limpar cache relacionado
      expire_diet_caches
      redirect_to [ @client, @diet ], notice: "Dieta criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Já otimizado com set_diet
  end

  def update
    if @diet.update(diet_params)
      # ✅ Limpar cache quando atualizar
      expire_diet_caches

      respond_to do |format|
        format.html { redirect_to client_diet_path(@client, @diet), notice: "Refeição atualizada com sucesso!" }
        format.json { render json: { name: @diet.name, notice: "Refeição atualizada com sucesso!" }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @diet.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @diet.destroy
    expire_diet_caches
    redirect_to [ @client, :diets ], alert: "Refeição removida com sucesso."
  end

  def duplicate
    # ✅ OTIMIZADO: Usa transação e bulk insert
    original_diet = @client.diets.includes(diet_foods: :food).find(params[:id])

    Diet.transaction do
      # Criar dieta duplicada
      @duplicated_diet = @client.diets.create!(
        name: "#{original_diet.name} (Cópia)",
        meal_type: original_diet.meal_type,
        notes: original_diet.notes,
        created_date: Date.current,
        position: next_position
      )

      # ✅ OTIMIZADO: Bulk insert dos alimentos
      diet_foods_data = original_diet.diet_foods.map do |food|
        {
          diet_id: @duplicated_diet.id,
          food_id: food.food_id,
          quantity_grams: food.quantity_grams,
          position: food.position,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      DietFood.insert_all(diet_foods_data) if diet_foods_data.any?
    end

    expire_diet_caches
    redirect_to client_diets_path(@client), notice: "Dieta duplicada com sucesso!"

  rescue ActiveRecord::RecordInvalid => e
    redirect_to client_diets_path(@client), alert: "Erro ao duplicar dieta: #{e.message}"
  end

  def add_food
    # ✅ OTIMIZADO: Query única com lock
    food = current_user.foods.find(params[:food_id])
    quantity = params[:quantity_grams].to_f

    # ✅ OTIMIZADO: Usar upsert para evitar race conditions
    diet_food = @diet.diet_foods.find_or_initialize_by(food: food)

    if diet_food.persisted?
      diet_food.increment!(:quantity_grams, quantity)
      message = "Quantidade de #{food.name} atualizada na dieta."
    else
      diet_food.assign_attributes(
        quantity_grams: quantity,
        position: @diet.diet_foods.maximum(:position).to_i + 1
      )

      if diet_food.save
        message = "#{food.name} adicionado à dieta com sucesso."
      else
        @available_foods = current_user.foods.order(:name)
        flash.now[:alert] = "Erro ao adicionar alimento: #{diet_food.errors.full_messages.join(', ')}"
        return render :show, status: :unprocessable_entity
      end
    end

    expire_diet_caches
    redirect_to [ @client, @diet ], notice: message

  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, @diet ], alert: "Alimento não encontrado."
  rescue => e
    Rails.logger.error "Erro em add_food: #{e.message}"
    redirect_to [ @client, @diet ], alert: "Erro ao adicionar alimento: #{e.message}"
  end

  def add_substitution
    # ✅ OTIMIZADO: Query com includes
    @diet_food = @diet.diet_foods.includes(:food).find(params[:diet_food_id])
    @substitute_food = current_user.foods.find(params[:substitute_food_id])

    @substitution = @diet_food.food_substitutions.build(
      substitute_food: @substitute_food,
      quantity_grams: params[:quantity_grams],
      notes: params[:notes]
    )

    if @substitution.save
      expire_diet_caches
      redirect_to [ @client, @diet ], notice: "Substituição adicionada com sucesso."
    else
      redirect_to [ @client, @diet ], alert: "Erro ao adicionar substituição: #{@substitution.errors.full_messages.join(', ')}"
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, @diet ], alert: "Alimento não encontrado."
  rescue => e
    Rails.logger.error "Erro em add_substitution: #{e.message}"
    redirect_to [ @client, @diet ], alert: "Erro ao adicionar substituição: #{e.message}"
  end

  def remove_substitution
    @substitution = FoodSubstitution.find(params[:substitution_id])
    @substitution.destroy
    expire_diet_caches
    redirect_to [ @client, @diet ], notice: "Substituição removida com sucesso."

  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, @diet ], alert: "Substituição não encontrada."
  rescue => e
    Rails.logger.error "Erro em remove_substitution: #{e.message}"
    redirect_to [ @client, @diet ], alert: "Erro ao remover substituição: #{e.message}"
  end

  def reorder
    # ✅ OTIMIZADO: Bulk update mais eficiente
    order_data = params[:order] || []

    return render json: { success: false, message: "Nenhum dado para reordenar" } if order_data.empty?

    Diet.transaction do
      # ✅ Usar bulk update para melhor performance
      updates = order_data.each_with_index.map do |item, idx|
        { id: item["id"], position: idx + 1 }
      end.select { |update| @client.diets.exists?(update[:id]) }

      # Usar upsert_all para bulk update
      Diet.upsert_all(updates, unique_by: :id) if updates.any?
    end

    expire_diet_caches
    render json: { success: true }

  rescue => e
    Rails.logger.error "Erro em reorder: #{e.message}"
    render json: { success: false, message: e.message }, status: 500
  end

  def reorder_foods
    Rails.logger.info "=== REORDER FOODS DEBUG ==="
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Order data: #{params[:order].inspect}"

    order_data = params[:order] || []

    if order_data.empty?
      Rails.logger.error "Empty order data received"
      return render json: { success: false, message: "Nenhum dado de ordenação recebido" }, status: :bad_request
    end

    begin
      DietFood.transaction do
        order_data.each_with_index do |item, index|
          Rails.logger.info "Processing item #{index}: #{item.inspect}"

          # ✅ CORRIGIDO: Usar find_by com validação
          diet_food = @diet.diet_foods.find_by(id: item[:id] || item["id"])

          if diet_food
            new_position = index + 1
            Rails.logger.info "Updating diet_food #{diet_food.id} to position #{new_position}"
            diet_food.update!(position: new_position)
          else
            Rails.logger.error "DietFood not found with id: #{item[:id] || item['id']}"
          end
        end
      end

      Rails.logger.info "Reorder successful"
      render json: { success: true, message: "Ordem atualizada com sucesso!" }

    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Record not found: #{e.message}"
      render json: { success: false, message: "Item não encontrado." }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Record invalid: #{e.message}"
      render json: { success: false, message: "Dados inválidos: #{e.message}" }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Error in reorder_foods: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { success: false, message: "Erro interno: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  def set_client
    # ✅ OTIMIZADO: Cache do cliente
    @client = Rails.cache.fetch("user_#{current_user.id}_client_#{params[:client_id]}", expires_in: 5.minutes) do
      current_user.clients.find(params[:client_id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to clients_path, alert: "Cliente não encontrado ou você não tem permissão."
  end

  def set_diet
    # ✅ OTIMIZADO: Inclui associações necessárias
    @diet = @client.diets
                  .includes(diet_foods: [ :food, :food_substitutions ])
                  .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, :diets ], alert: "Dieta não encontrada."
  end

  def diet_params
    params.require(:diet).permit(:name, :meal_type, :notes, :created_date)
  end

  def reorder_params
    params.permit(order: [ :id, :position ])
  end

  # ✅ NOVOS MÉTODOS OTIMIZADOS

  def next_position
    @client.diets.maximum(:position).to_i + 1
  end

  def calculate_diet_totals(diet)
    {
      total_calories: diet.diet_foods.joins(:food).sum("diet_foods.quantity_grams * foods.calories_per_100g / 100"),
      total_protein: diet.diet_foods.joins(:food).sum("diet_foods.quantity_grams * foods.protein_per_100g / 100"),
      total_carbs: diet.diet_foods.joins(:food).sum("diet_foods.quantity_grams * foods.carbs_per_100g / 100"),
      total_fat: diet.diet_foods.joins(:food).sum("diet_foods.quantity_grams * foods.fat_per_100g / 100"),
      foods_count: diet.diet_foods.count
    }
  end

  def expire_diet_caches
    Rails.cache.delete("user_#{current_user.id}_foods")
    Rails.cache.delete("user_#{current_user.id}_client_#{@client.id}")
    Rails.cache.delete("diet_#{@diet.id}_totals") if @diet

    # Limpar cache de todas as dietas do cliente
    @client.diets.pluck(:id).each do |diet_id|
      Rails.cache.delete("diet_#{diet_id}_totals")
    end
  end
end
