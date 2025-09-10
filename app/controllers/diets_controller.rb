class DietsController < ApplicationController
  before_action :set_client
  before_action :set_diet, only: [ :show, :edit, :update, :destroy, :add_food, :add_substitution, :remove_substitution ]

  def index
    @diets = @client.diets.order(:meal_type)
    @daily_total_calories = @diets.sum(&:total_calories)
  end

  def show
    @available_foods = current_user.foods.order(:name)
    @diet_food = DietFood.new
  end

  def new
    @diet = @client.diets.build
  end

  def create
    @diet = current_user.diets.build(diet_params)
    @diet.client = @client
    @diet.created_date = Date.current

    if @diet.save
      redirect_to [ @client, @diet ], notice: "Dieta criada com sucesso."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @diet.update(diet_params)
      redirect_to [ @client, @diet ], notice: "Dieta atualizada com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @diet.destroy
    redirect_to [ @client, :diets ], notice: "Dieta removida com sucesso."
  end

  def add_food
    # Os parâmetros vêm diretamente do form, não aninhados
    food = current_user.foods.find(params[:food_id])
    quantity = params[:quantity_grams].to_f

    # Verificar se já existe este alimento na dieta
    existing_diet_food = @diet.diet_foods.find_by(food: food)

    if existing_diet_food
      # Se já existe, atualizar a quantidade
      existing_diet_food.update(quantity_grams: existing_diet_food.quantity_grams + quantity)
      redirect_to [ @client, @diet ], notice: "Quantidade de #{food.name} atualizada na dieta."
    else
      # Se não existe, criar novo
      diet_food = @diet.diet_foods.build(
        food: food,
        quantity_grams: quantity
      )

      if diet_food.save
        redirect_to [ @client, @diet ], notice: "#{food.name} adicionado à dieta com sucesso."
      else
        @available_foods = current_user.foods.order(:name)
        flash.now[:alert] = "Erro ao adicionar alimento: #{diet_food.errors.full_messages.join(', ')}"
        render :show
      end
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, @diet ], alert: "Alimento não encontrado."
  rescue => e
    redirect_to [ @client, @diet ], alert: "Erro ao adicionar alimento: #{e.message}"
  end

  def add_substitution
    @diet_food = @diet.diet_foods.find(params[:diet_food_id])
    @substitute_food = current_user.foods.find(params[:substitute_food_id])

    @substitution = @diet_food.food_substitutions.build(
      substitute_food: @substitute_food,
      quantity_grams: params[:quantity_grams],
      notes: params[:notes]
    )

    if @substitution.save
      redirect_to [ @client, @diet ], notice: "Substituição adicionada com sucesso."
    else
      redirect_to [ @client, @diet ], alert: "Erro ao adicionar substituição: #{@substitution.errors.full_messages.join(', ')}"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, @diet ], alert: "Alimento não encontrado."
  rescue => e
    redirect_to [ @client, @diet ], alert: "Erro ao adicionar substituição: #{e.message}"
  end

  def remove_substitution
    @substitution = FoodSubstitution.find(params[:substitution_id])
    @substitution.destroy
    redirect_to [ @client, @diet ], notice: "Substituição removida com sucesso."
  rescue ActiveRecord::RecordNotFound
    redirect_to [ @client, @diet ], alert: "Substituição não encontrada."
  rescue => e
    redirect_to [ @client, @diet ], alert: "Erro ao remover substituição: #{e.message}"
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_diet
    @diet = @client.diets.find(params[:id])
  end

  def diet_params
    params.require(:diet).permit(:name, :meal_type, :notes)
  end
end
