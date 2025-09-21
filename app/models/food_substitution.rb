class FoodSubstitution < ApplicationRecord
  belongs_to :diet_food
  belongs_to :substitute_food, class_name: 'Food'
  
  validates :quantity_grams, presence: true, numericality: { greater_than: 0 }
end
