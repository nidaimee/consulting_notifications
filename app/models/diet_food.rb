class DietFood < ApplicationRecord
  belongs_to :diet
  belongs_to :food

  # Relacionamento com substituições
  has_many :food_substitutions, dependent: :destroy

  validates :quantity_grams, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_nutrients
  before_create :set_position
  after_update :calculate_nutrients

  # Aceitar parâmetros aninhados para substituições
  accepts_nested_attributes_for :food_substitutions, allow_destroy: true, reject_if: :all_blank

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

  # Métodos para reordenação
  def move_up!
    return false if first_position?

    transaction do
      previous_item = diet.diet_foods.where("position < ?", position).order(position: :desc).first
      if previous_item
        self.class.where(id: [ id, previous_item.id ]).update_all(
          "position = CASE
            WHEN id = #{id} THEN #{previous_item.position}
            WHEN id = #{previous_item.id} THEN #{position}
          END"
        )
      end
    end
    reload
    true
  end

  def move_down!
    return false if last_position?

    transaction do
      next_item = diet.diet_foods.where("position > ?", position).order(position: :asc).first
      if next_item
        self.class.where(id: [ id, next_item.id ]).update_all(
          "position = CASE
            WHEN id = #{id} THEN #{next_item.position}
            WHEN id = #{next_item.id} THEN #{position}
          END"
        )
      end
    end
    reload
    true
  end

  def first_position?
    position <= 1 || diet.diet_foods.where("position < ?", position).empty?
  end

  def last_position?
    diet.diet_foods.where("position > ?", position).empty?
  end

  private

  def set_position
    if self.position.blank?
      self.position = (diet.diet_foods.maximum(:position) || 0) + 1
    end
  end

  def calculate_nutrients
    self.calories = calculated_calories.round(2)
    self.protein = calculated_protein.round(2)
    self.carbs = calculated_carbs.round(2)
    self.fat = calculated_fat.round(2)
  end
end
