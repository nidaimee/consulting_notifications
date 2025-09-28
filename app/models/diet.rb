class Diet < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :diet_foods, dependent: :destroy
  has_many :foods, through: :diet_foods
  validates :name, presence: true

  def foods_list
    diet_foods.includes(:food).map { |df| df.food.name }.join(", ")
  end

  def foods_with_quantities
    diet_foods.includes(:food).map { |df| "#{df.quantity_grams.to_i}g #{df.food.name}" }.join(" • ")
  end

  # ✅ CORRIGIDO: Cálculos baseados nos alimentos e suas quantidades
  def total_calories
    diet_foods.includes(:food).sum do |diet_food|
      next 0 unless diet_food.food && diet_food.quantity_grams && diet_food.food.calories_per_100g
      (diet_food.quantity_grams * diet_food.food.calories_per_100g) / 100.0
    end.round(1)
  end

  def total_protein
    diet_foods.includes(:food).sum do |diet_food|
      next 0 unless diet_food.food && diet_food.quantity_grams && diet_food.food.protein_per_100g
      (diet_food.quantity_grams * diet_food.food.protein_per_100g) / 100.0
    end.round(1)
  end

  def total_carbs
    diet_foods.includes(:food).sum do |diet_food|
      next 0 unless diet_food.food && diet_food.quantity_grams && diet_food.food.carbs_per_100g
      (diet_food.quantity_grams * diet_food.food.carbs_per_100g) / 100.0
    end.round(1)
  end

  def total_fat
    diet_foods.includes(:food).sum do |diet_food|
      next 0 unless diet_food.food && diet_food.quantity_grams && diet_food.food.fat_per_100g
      (diet_food.quantity_grams * diet_food.food.fat_per_100g) / 100.0
    end.round(1)
  end

  private
end
