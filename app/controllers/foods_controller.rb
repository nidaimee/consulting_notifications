class FoodsController < ApplicationController
  before_action :set_food, only: [:show, :edit, :update, :destroy]

  def index
    @foods = current_user.foods.order(:category, :name)
    @categories = current_user.foods.distinct.pluck(:category).compact.sort
  end

  def show
  end

  def new
    @food = current_user.foods.build
  end

  def create
    @food = current_user.foods.build(food_params)
    
    if @food.save
      redirect_to @food, notice: 'Alimento criado com sucesso.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @food.update(food_params)
      redirect_to @food, notice: 'Alimento atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @food.destroy
    redirect_to foods_url, notice: 'Alimento removido com sucesso.'
  end

  private

  def set_food
    @food = current_user.foods.find(params[:id])
  end

  def food_params
    params.require(:food).permit(:name, :calories_per_100g, :protein_per_100g, 
                                 :carbs_per_100g, :fat_per_100g, :category)
  end
end
