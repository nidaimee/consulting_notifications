# app/controllers/diet_foods_controller.rb

class DietFoodsController < ApplicationController
  include TailadminLayout
  before_action :authenticate_user!
  before_action :set_client_and_diet
  before_action :set_diet_food, only: [ :update, :destroy, :move_up, :move_down ]

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
      respond_to do |format|
        format.html {
          redirect_to client_diet_path(@client, @diet),
                      notice: "Quantidade atualizada com sucesso!"
        }
        format.json {
          # Recalcular valores nutricionais
          nutrition = {
            protein: @diet_food.calculated_protein.round(1),
            carbs: @diet_food.calculated_carbs.round(1),
            fat: @diet_food.calculated_fat.round(1),
            calories: @diet_food.calculated_calories.round(1)
          }

          render json: {
            success: true,
            message: "Quantidade atualizada com sucesso!",
            nutrition: nutrition
          }
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to client_diet_path(@client, @diet),
                      alert: "Erro ao atualizar quantidade: #{@diet_food.errors.full_messages.join(', ')}"
        }
        format.json {
          render json: {
            success: false,
            message: "Erro ao atualizar quantidade: #{@diet_food.errors.full_messages.join(', ')}"
          }, status: 422
        }
      end
    end
  end

  def destroy
    @diet_food.destroy
    redirect_to client_diet_path(@client, @diet), alert: "Alimento removido da dieta!"
  end

  def move_up
    if @diet_food.move_up!
      redirect_to client_diet_path(@client, @diet), notice: "Alimento movido para cima!"
    else
      redirect_to client_diet_path(@client, @diet), alert: "Não foi possível mover o alimento."
    end
  end

  def move_down
    if @diet_food.move_down!
      redirect_to client_diet_path(@client, @diet), notice: "Alimento movido para baixo!"
    else
      redirect_to client_diet_path(@client, @diet), alert: "Não foi possível mover o alimento."
    end
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
    params.require(:diet_food).permit(:quantity_grams, :calories, :protein, :carbs, :fat, :notes)
  end
end
