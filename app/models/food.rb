class Food < ApplicationRecord
  # Associações
  belongs_to :user
  belongs_to :food_category, foreign_key: :category, primary_key: :key, optional: true
  has_many :diet_foods
  has_many :food_substitutions_as_original, class_name: "FoodSubstitution", foreign_key: "diet_food_id"
  has_many :food_substitutions_as_substitute, class_name: "FoodSubstitution", foreign_key: "substitute_food_id"

  # Validações
  validates :name, presence: true
  validates :calories_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :protein_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :carbs_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fat_per_100g, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_category, ->(category) { where(category: category) }
  scope :with_portion, -> { where.not(portion_grams: nil) }
  scope :categorized, -> { where.not(category: nil) }
  before_validation :set_default_nutritional_values

  # Delegate
  delegate :name, to: :food_category, prefix: :category, allow_nil: true

  # Métodos de instância
  def has_category?
    category.present?
  end

  def calculate_portions(quantity_grams)
    return 1 unless portion_grams.present? && portion_grams > 0
    (quantity_grams.to_f / portion_grams.to_f).round(2)
  end

  def calculate_substitute_quantity(original_quantity, substitute_portion)
    return original_quantity unless portion_grams.present? && portion_grams > 0

    portions = calculate_portions(original_quantity)
    (portions * substitute_portion).round
  end

  # Busca alimentos substitutos da mesma categoria
  def possible_substitutes
    return Food.none unless category.present?

    Food.by_category(category)
        .where.not(id: id)
        .with_portion
  end

  # Busca equivalências padrão da categoria
  def category_equivalences
    return FoodEquivalence.none unless category.present?

    FoodEquivalence.where(category: category).order(:display_order, :food_name)
  end

  # Gera lista de substituições com quantidades calculadas
  def substitutions_for(quantity_grams)
    return [] unless category.present? && portion_grams.present?

    portions = calculate_portions(quantity_grams)

    category_equivalences.map do |equiv|
      {
        name: equiv.food_name,
        quantity: (portions * equiv.portion_grams).round,
        unit: equiv.portion_unit || "g"
      }
    end
  end

  # Scopes
  scope :by_category, ->(category) { where(category: category) }
  scope :with_portion, -> { where.not(portion_grams: nil) }
  scope :categorized, -> { where.not(category: nil) }
  private
   def set_default_nutritional_values
    self.calories_per_100g ||= 0.0
    self.protein_per_100g ||= 0.0
    self.carbs_per_100g ||= 0.0
    self.fat_per_100g ||= 0.0
  end
end
