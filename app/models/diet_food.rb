class DietFood < ApplicationRecord
  belongs_to :diet
  belongs_to :food
  has_many :food_substitutions, dependent: :destroy
  
  validates :quantity_grams, presence: true, numericality: { greater_than: 0 }
  
  before_save :calculate_nutrients
  after_update :calculate_nutrients
  
  # Cálculos proporcionais baseados na quantidade
  def calculated_calories
    calculate_proportion(food.calories_per_100g)
  end
  
  def calculated_protein
    calculate_proportion(food.protein_per_100g)
  end
  
  def calculated_carbs
    calculate_proportion(food.carbs_per_100g)
  end
  
  def calculated_fat
    calculate_proportion(food.fat_per_100g)
  end
  
  # Exemplo: 150g de frango (165 kcal/100g) = (150 * 165) / 100 = 247.5 kcal
  def calculate_proportion(value_per_100g)
    (quantity_grams.to_f * value_per_100g.to_f) / 100.0
  end
  
  # Resumo formatado para exibição
  def nutrition_summary
    "#{calculated_calories.round(1)}kcal | P:#{calculated_protein.round(1)}g | C:#{calculated_carbs.round(1)}g | F:#{calculated_fat.round(1)}g"
  end
  
  private
  
  def calculate_nutrients
    self.calories = calculated_calories.round(2)
    self.protein = calculated_protein.round(2)
    self.carbs = calculated_carbs.round(2)
    self.fat = calculated_fat.round(2)
  end
end
