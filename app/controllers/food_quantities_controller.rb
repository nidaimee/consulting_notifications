class FoodQuantitiesController < ApplicationController
  before_action :set_food_quantity, only: [ :destroy ]

  def destroy
    fq = FoodQuantity.find(params[:id])
    fq.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_back fallback_location: edit_food_path(fq.food), notice: "Unidade removida." }
    end
  end

  private

  def set_food_quantity
    @food_quantity = FoodQuantity.find(params[:id])
  end
end
