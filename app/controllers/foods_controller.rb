class FoodsController < ApplicationController
  include TailadminLayout
  before_action :set_food, only: [ :show, :edit, :update, :destroy ]

  def index
    @foods = current_user.foods.order(:category, :name)

    # Aplicar filtro de busca por nome
    if params[:search].present?
      search_term = "%#{params[:search].strip}%"
      @foods = @foods.where("name ILIKE ?", search_term)
    end

    # Aplicar filtro por categoria
    if params[:category].present?
      @foods = @foods.where(category: params[:category])
    end

    @categories = current_user.foods.distinct.pluck(:category).compact.sort
  end

  def show
  end

  def new
    @food = current_user.foods.build(
      # Valores padrão para evitar campos vazios
      calories_per_100g: 0,
      protein_per_100g: 0,
      carbs_per_100g: 0,
      fat_per_100g: 0,
      portion_grams: 100
    )

    # Pre-popular o nome se vier da busca
    @food.name = params[:name] if params[:name].present?
  end

  def create
    @food = current_user.foods.build(food_params)

    if @food.save
      redirect_to @food, notice: "Alimento criado com sucesso."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @food.update(food_params)
      redirect_to edit_food_path(@food), notice: "Alimento atualizado com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @food_quantity = FoodQuantity.find_by(id: params[:id])
    if @food_quantity
      @food_quantity.destroy
      redirect_back(fallback_location: edit_food_path(@food_quantity.food), notice: "Unidade removida com sucesso.")
    else
      redirect_back(fallback_location: root_path, alert: "Unidade não encontrada.")
    end
  end

  private

  def set_food
    @food = current_user.foods.find(params[:id])
  end

  def food_params
    params.require(:food).permit(:name, :calories_per_100g, :protein_per_100g,
                                 :carbs_per_100g, :fat_per_100g, :category, food_quantities_attributes: [ :id, :name, :grams, :_destroy ])
  end

  def ensure_nutritional_values
    @food.calories_per_100g ||= 0
    @food.protein_per_100g ||= 0
    @food.carbs_per_100g ||= 0
    @food.fat_per_100g ||= 0
  end
end
