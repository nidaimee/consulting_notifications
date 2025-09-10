class FoodEquivalence < ApplicationRecord
  belongs_to :food_category, foreign_key: :category, primary_key: :key, optional: true

  validates :category, :food_name, :portion_grams, presence: true
  validates :portion_grams, numericality: { greater_than: 0 }

  scope :by_category, ->(category) { where(category: category) }
  scope :ordered, -> { order(:display_order, :food_name) }

  delegate :name, to: :food_category, prefix: :category, allow_nil: true
end
