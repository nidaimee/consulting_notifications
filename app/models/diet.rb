class Diet < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :diet_foods, dependent: :destroy
  has_many :foods, through: :diet_foods

  validates :name, presence: true
  validates :meal_type, presence: true

  def foods_list
    diet_foods.includes(:food).map { |df| df.food.name }.join(", ")
  end
  def foods_with_quantities
    diet_foods.includes(:food).map { |df| "#{df.quantity_grams.to_i}g #{df.food.name}" }.join(" • ")
  end
  # Cálculos automáticos dos totais
  def total_calories
    diet_foods.sum(&:calories) || 0
  end

  def total_protein
    diet_foods.sum(&:protein) || 0
  end

  def total_carbs
    diet_foods.sum(&:carbs) || 0
  end

  def total_fat
    diet_foods.sum(&:fat) || 0
  end
end
