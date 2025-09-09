class DietFoodsController < ApplicationController
  before_action :set_client_and_diet
  before_action :set_diet_food

  def destroy
    food_name = @diet_food.food.name
    @diet_food.destroy
    redirect_to client_diet_path(@client, @diet), 
                notice: "#{food_name} removido da dieta com sucesso."
  end

  private

  def set_client_and_diet
    @client = current_user.clients.find(params[:client_id])
    @diet = @client.diets.find(params[:diet_id])
  end

  def set_diet_food
    @diet_food = @diet.diet_foods.find(params[:id])
  end
end
