class FoodSubstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client_and_diet
  before_action :set_substitution, only: [ :update, :destroy ]

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

  def update
    if @substitution.update(quantity_grams: params[:quantity_grams])
      respond_to do |format|
        format.json {
          render json: {
            success: true,
            protein: @substitution.calculated_protein.round(1),
            carbs: @substitution.calculated_carbs.round(1),
            fat: @substitution.calculated_fat.round(1),
            calories: @substitution.calculated_calories.round(1),
            message: "Quantidade atualizada com sucesso!"
          }
        }
        format.html {
          redirect_to client_diet_path(@client, @diet),
                      notice: "Quantidade da substituição atualizada!"
        }
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            success: false,
            message: @substitution.errors.full_messages.join(", ")
          }, status: :unprocessable_entity
        }
        format.html {
          redirect_to client_diet_path(@client, @diet),
                      alert: "Erro ao atualizar quantidade."
        }
      end
    end
  end

  def destroy
    @substitution.destroy
    redirect_to client_diet_path(@client, @diet),
                alert: "Substituição removida com sucesso!"
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
