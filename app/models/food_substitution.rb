class FoodSubstitution < ApplicationRecord
  belongs_to :diet_food
  belongs_to :substitute_food, class_name: "Food", foreign_key: "substitute_food_id"

  validates :quantity_grams, presence: true, numericality: { greater_than: 0 }

  def calculated_calories
    (quantity_grams.to_f * substitute_food.calories_per_100g.to_f) / 100.0
  end

  def calculated_protein
    (quantity_grams.to_f * substitute_food.protein_per_100g.to_f) / 100.0
  end

  def calculated_carbs
    (quantity_grams.to_f * substitute_food.carbs_per_100g.to_f) / 100.0
  end

  def calculated_fat
    (quantity_grams.to_f * substitute_food.fat_per_100g.to_f) / 100.0
  end
end
