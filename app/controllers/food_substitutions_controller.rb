class FoodSubstitutionsController < ApplicationController
  include TailadminLayout
  before_action :authenticate_user!
  before_action :set_client_and_diet
  before_action :set_diet_food, only: [ :create ]
  before_action :set_substitution, only: [ :show, :edit, :update, :destroy ]

  def index
    # ✅ NOVO: Lista todas as substituições da dieta
    @substitutions = @diet.diet_foods
                          .joins(:food_substitutions)
                          .includes(
                            food_substitutions: [ :substitute_food ],
                            food: []
                          )
                          .order("diet_foods.position, food_substitutions.created_at")

    # ✅ Cache das estatísticas
    @substitution_stats = Rails.cache.fetch("diet_#{@diet.id}_substitution_stats", expires_in: 10.minutes) do
      calculate_substitution_stats
    end
  end

  def show
    # ✅ OTIMIZADO: Já carregado com includes no set_substitution
  end

  def new
    @diet_food = @diet.diet_foods.includes(:food).find(params[:diet_food_id])
    @substitution = @diet_food.food_substitutions.build

    # ✅ Cache dos alimentos disponíveis
    @available_foods = Rails.cache.fetch("user_#{current_user.id}_foods_for_substitution", expires_in: 10.minutes) do
      current_user.foods
                  .where.not(id: @diet_food.food_id) # Excluir o alimento principal
                  .select(:id, :name, :calories_per_100g, :protein_per_100g, :carbs_per_100g, :fat_per_100g)
                  .order(:name)
                  .to_a
    end
  end

  def create
    # ✅ OTIMIZADO: Transação e validações robustas
    ActiveRecord::Base.transaction do
      @substitute_food = current_user.foods.find(params[:substitute_food_id])

      # ✅ Verificar se já existe esta substituição
      existing_substitution = @diet_food.food_substitutions
                                       .find_by(substitute_food: @substitute_food)

      if existing_substitution
        # ✅ Atualizar quantidade se já existir
        new_quantity = existing_substitution.quantity_grams + params[:quantity_grams].to_f

        if existing_substitution.update(quantity_grams: new_quantity)
          expire_substitution_caches
          redirect_to client_diet_path(@client, @diet),
                     notice: "Quantidade da substituição '#{@substitute_food.name}' atualizada (#{new_quantity}g)!"
        else
          redirect_to client_diet_path(@client, @diet),
                     alert: "Erro ao atualizar substituição: #{existing_substitution.errors.full_messages.join(', ')}"
        end
      else
        # ✅ Criar nova substituição
        @substitution = @diet_food.food_substitutions.build(substitution_params)
        @substitution.substitute_food = @substitute_food

        if @substitution.save
          expire_substitution_caches
          redirect_to client_diet_path(@client, @diet),
                     notice: "Substituição '#{@substitute_food.name}' adicionada com sucesso!"
        else
          Rails.logger.error "Substitution creation failed: #{@substitution.errors.full_messages}"
          redirect_to client_diet_path(@client, @diet),
                     alert: "Erro ao adicionar substituição: #{@substitution.errors.full_messages.join(', ')}"
        end
      end
    end

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Food not found for substitution: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Alimento não encontrado."
  rescue => e
    Rails.logger.error "Error creating substitution: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro inesperado ao criar substituição."
  end

  def edit
    # ✅ Carregar alimentos para edição
    @available_foods = Rails.cache.fetch("user_#{current_user.id}_foods_for_substitution", expires_in: 10.minutes) do
      current_user.foods
                  .where.not(id: @substitution.diet_food.food_id)
                  .select(:id, :name, :calories_per_100g, :protein_per_100g, :carbs_per_100g, :fat_per_100g)
                  .order(:name)
                  .to_a
    end
  end

  def update
    # ✅ OTIMIZADO: Transação e cálculos otimizados
    ActiveRecord::Base.transaction do
      if @substitution.update(substitution_params)
        expire_substitution_caches

        # ✅ Cache dos cálculos nutricionais
        nutrition = Rails.cache.fetch("substitution_#{@substitution.id}_nutrition", expires_in: 1.hour) do
          calculate_substitution_nutrition(@substitution)
        end

        respond_to do |format|
          format.json {
            render json: {
              success: true,
              nutrition: nutrition,
              message: "Quantidade atualizada com sucesso!",
              updated_at: @substitution.updated_at.strftime("%H:%M")
            }
          }
          format.html {
            redirect_to client_diet_path(@client, @diet),
                       notice: "Quantidade da substituição atualizada!"
          }
        end
      else
        Rails.logger.error "Substitution update failed: #{@substitution.errors.full_messages}"

        respond_to do |format|
          format.json {
            render json: {
              success: false,
              message: @substitution.errors.full_messages.join(", ")
            }, status: :unprocessable_entity
          }
          format.html {
            render :edit, status: :unprocessable_entity
          }
        end
      end
    end

  rescue => e
    Rails.logger.error "Error updating substitution: #{e.message}"
    respond_to do |format|
      format.json {
        render json: { success: false, message: "Erro inesperado." }, status: :internal_server_error
      }
      format.html {
        redirect_to client_diet_path(@client, @diet), alert: "Erro inesperado ao atualizar."
      }
    end
  end

  def destroy
    substitute_food_name = @substitution.substitute_food.name

    ActiveRecord::Base.transaction do
      @substitution.destroy!
      expire_substitution_caches
    end

    redirect_to client_diet_path(@client, @diet),
               notice: "Substituição '#{substitute_food_name}' removida com sucesso!"

  rescue => e
    Rails.logger.error "Error destroying substitution: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro ao remover substituição."
  end

  # ✅ NOVO: Bulk operations
  def bulk_destroy
    substitution_ids = params[:substitution_ids].to_a.map(&:to_i)

    ActiveRecord::Base.transaction do
      destroyed_count = FoodSubstitution.joins(diet_food: { diet: :client })
                                       .where(
                                         id: substitution_ids,
                                         diets: { client: @client }
                                       )
                                       .destroy_all.count

      expire_substitution_caches
      redirect_to client_diet_path(@client, @diet),
                 notice: "#{destroyed_count} substituições removidas com sucesso!"
    end

  rescue => e
    Rails.logger.error "Error in bulk destroy: #{e.message}"
    redirect_to client_diet_path(@client, @diet), alert: "Erro ao remover substituições selecionadas."
  end

  # ✅ NOVO: Quick add substitution via AJAX
  def quick_add
    diet_food = @diet.diet_foods.includes(:food).find(params[:diet_food_id])
    substitute_food = current_user.foods.find(params[:substitute_food_id])
    quantity = params[:quantity].to_f

    ActiveRecord::Base.transaction do
      substitution = diet_food.food_substitutions.create!(
        substitute_food: substitute_food,
        quantity_grams: quantity
      )

      expire_substitution_caches

      nutrition = calculate_substitution_nutrition(substitution)

      render json: {
        success: true,
        message: "#{substitute_food.name} adicionado como substituição!",
        substitution: {
          id: substitution.id,
          name: substitute_food.name,
          quantity: quantity,
          nutrition: nutrition
        }
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

  # ✅ NOVO: Comparação nutricional
  def compare
    diet_food = @diet.diet_foods.includes(:food, food_substitutions: :substitute_food).find(params[:diet_food_id])

    # ✅ Cache da comparação
    comparison = Rails.cache.fetch("diet_food_#{diet_food.id}_comparison", expires_in: 30.minutes) do
      generate_nutrition_comparison(diet_food)
    end

    render json: comparison
  end

  private

  def set_client_and_diet
    # ✅ OTIMIZADO: Cache e includes estratégicos
    @client = Rails.cache.fetch("user_#{current_user.id}_client_#{params[:client_id]}", expires_in: 5.minutes) do
      current_user.clients.includes(:diets).find(params[:client_id])
    end

    @diet = @client.diets
                  .includes(diet_foods: [ :food, { food_substitutions: :substitute_food } ])
                  .find(params[:diet_id])

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Client or Diet not found: #{e.message}"
    redirect_to clients_path, alert: "Cliente ou dieta não encontrada."
  end

  def set_diet_food
    @diet_food = @diet.diet_foods.includes(:food).find(params[:diet_food_id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "DietFood not found: #{params[:diet_food_id]}"
    redirect_to client_diet_path(@client, @diet), alert: "Item da dieta não encontrado."
  end

  def set_substitution
    # ✅ OTIMIZADO: Includes com validação de segurança
    @substitution = FoodSubstitution.joins(diet_food: { diet: :client })
                                   .includes(:substitute_food, diet_food: [ :food, { diet: :client } ])
                                   .where(
                                     id: params[:id],
                                     diets: { client: @client }
                                   )
                                   .first

    unless @substitution
      Rails.logger.error "Substitution not found or unauthorized: #{params[:id]}"
      redirect_to client_diet_path(@client, @diet), alert: "Substituição não encontrada."
    end
  end

  def substitution_params
    params.require(:food_substitution).permit(:quantity_grams, :notes, :substitute_food_id)
  end

  # ✅ NOVOS MÉTODOS DE OTIMIZAÇÃO

  def calculate_substitution_nutrition(substitution)
    return {} unless substitution.substitute_food && substitution.quantity_grams

    food = substitution.substitute_food
    quantity_ratio = substitution.quantity_grams / 100.0

    {
      protein: (food.protein_per_100g * quantity_ratio).round(1),
      carbs: (food.carbs_per_100g * quantity_ratio).round(1),
      fat: (food.fat_per_100g * quantity_ratio).round(1),
      calories: (food.calories_per_100g * quantity_ratio).round(1)
    }
  end

  def calculate_substitution_stats
    substitutions = @diet.diet_foods.joins(:food_substitutions).includes(food_substitutions: :substitute_food)

    {
      total_substitutions: substitutions.sum { |df| df.food_substitutions.count },
      unique_substitute_foods: substitutions.map { |df| df.food_substitutions.map(&:substitute_food_id) }.flatten.uniq.count,
      most_substituted: substitutions.max_by { |df| df.food_substitutions.count }&.food&.name,
      total_calories_from_substitutions: substitutions.sum do |df|
        df.food_substitutions.sum do |sub|
          (sub.quantity_grams * sub.substitute_food.calories_per_100g) / 100.0
        end
      end.round(1)
    }
  end

  def generate_nutrition_comparison(diet_food)
    original_nutrition = calculate_substitution_nutrition(
      OpenStruct.new(
        substitute_food: diet_food.food,
        quantity_grams: diet_food.quantity_grams
      )
    )

    substitutions_nutrition = diet_food.food_substitutions.map do |sub|
      {
        id: sub.id,
        name: sub.substitute_food.name,
        quantity: sub.quantity_grams,
        nutrition: calculate_substitution_nutrition(sub)
      }
    end

    {
      original: {
        name: diet_food.food.name,
        quantity: diet_food.quantity_grams,
        nutrition: original_nutrition
      },
      substitutions: substitutions_nutrition
    }
  end

  def expire_substitution_caches
    Rails.cache.delete("diet_#{@diet.id}_substitution_stats")
    Rails.cache.delete("client_#{@client.id}_daily_totals")
    Rails.cache.delete("user_#{current_user.id}_client_#{@client.id}")

    # Limpar cache de nutrition de todas as substituições
    @diet.diet_foods.joins(:food_substitutions).pluck("food_substitutions.id").each do |sub_id|
      Rails.cache.delete("substitution_#{sub_id}_nutrition")
    end

    # Limpar comparações
    @diet.diet_foods.pluck(:id).each do |diet_food_id|
      Rails.cache.delete("diet_food_#{diet_food_id}_comparison")
    end
  end
end
