class FoodSubstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client_and_diet
  before_action :set_substitution, only: [ :destroy ]

  def create
    @diet_food = @diet.diet_foods.find(params[:diet_food_id])
    @substitute_food = current_user.foods.find(params[:substitute_food_id])

    @substitution = @diet_food.food_substitutions.build(
      substitute_food: @substitute_food,
      quantity_grams: params[:quantity_grams]
    )

    if @substitution.save
      redirect_to client_diet_path(@client, @diet),
                  notice: "Substituição adicionada com sucesso!"
    else
      redirect_to client_diet_path(@client, @diet),
                  alert: "Erro ao adicionar substituição."
    end
  end

  def destroy
    @substitution.destroy
    redirect_to client_diet_path(@client, @diet),
                notice: "Substituição removida com sucesso!"
  end

  private

  def set_client_and_diet
    @client = current_user.clients.find(params[:client_id])
    @diet = @client.diets.find(params[:diet_id])
  end

  def set_substitution
    @substitution = FoodSubstitution.find(params[:id])
  end
end
