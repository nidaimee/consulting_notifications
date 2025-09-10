# app/controllers/diet_foods_controller.rb

class DietFoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client_and_diet
  before_action :set_diet_food, only: [ :update, :destroy ]

  def create
    @food = current_user.foods.find(params[:diet_food][:food_id])
    @diet_food = @diet.diet_foods.build(diet_food_params)

    if @diet_food.save
      redirect_to client_diet_path(@client, @diet),
                  notice: "Alimento adicionado à dieta com sucesso!"
    else
      redirect_to client_diet_path(@client, @diet),
                  alert: "Erro ao adicionar alimento: " + @diet_food.errors.full_messages.join(", ")
    end
  end

  def update
    if @diet_food.update(diet_food_params)
      redirect_to client_diet_path(@client, @diet),
                  notice: "Quantidade atualizada com sucesso!"
    else
      redirect_to client_diet_path(@client, @diet),
                  alert: "Erro ao atualizar quantidade."
    end
  end

  def destroy
    @diet_food.destroy
    redirect_to client_diet_path(@client, @diet), notice: "Alimento removido da dieta!"
  end



  private

   def set_client_and_diet
    @client = current_user.clients.find(params[:client_id])
    @diet = @client.diets.find(params[:diet_id])
  end

  def set_diet_food
    @diet_food = @diet.diet_foods.find(params[:id])
  end

  def diet_food_params
    params.require(:diet_food).permit(:food_id, :quantity_grams)
  end
end
