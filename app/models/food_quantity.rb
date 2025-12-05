class FoodQuantity < ApplicationRecord
  has_many :diet_foods
  belongs_to :food
  validates :name, presence: true
  validates :grams, presence: true, numericality: { greater_than: 0 }
end
