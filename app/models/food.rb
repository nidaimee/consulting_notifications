class Food < ApplicationRecord
  belongs_to :user
  has_many :diet_foods, dependent: :destroy
  has_many :diets, through: :diet_foods

  validates :name, presence: true
  validates :calories_per_100g, presence: true, numericality: { greater_than: 0 }
  validates :protein_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :carbs_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fat_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :by_category, ->(category) { where(category: category) }
end
