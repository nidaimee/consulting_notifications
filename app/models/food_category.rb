class FoodCategory < ApplicationRecord
  has_many :foods, foreign_key: :category, primary_key: :key
  has_many :food_equivalences, foreign_key: :category, primary_key: :key

  validates :key, :name, presence: true
  validates :key, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:display_order, :name) }

  def self.seed_categories
    categories = [
      { key: "vegetais_a", name: "Vegetais A (Livres)", color: "#27ae60", display_order: 1,
        description: "Vegetais com baixo valor calórico, podem ser consumidos à vontade" },
      { key: "vegetais_b", name: "Vegetais B", color: "#16a085", display_order: 2,
        description: "Vegetais com maior teor de carboidratos" },
      { key: "proteina_magra", name: "Proteínas Magras", color: "#e74c3c", display_order: 3,
        description: "Carnes magras e fontes de proteína com baixo teor de gordura" },
      { key: "proteina_media", name: "Proteínas Médias", color: "#c0392b", display_order: 4,
        description: "Proteínas com teor médio de gordura" },
      { key: "frutas", name: "Frutas", color: "#f39c12", display_order: 5,
        description: "Todas as frutas frescas" },
      { key: "laticinios", name: "Laticínios", color: "#3498db", display_order: 6,
        description: "Leite e derivados" },
      { key: "carboidrato_complexo", name: "Carboidratos Complexos", color: "#9b59b6", display_order: 7,
        description: "Fontes de carboidratos de absorção lenta" },
      { key: "carboidrato_simples", name: "Carboidratos Simples", color: "#8e44ad", display_order: 8,
        description: "Fontes de carboidratos de absorção rápida" },
      { key: "leguminosas", name: "Leguminosas", color: "#34495e", display_order: 9,
        description: "Feijões, lentilhas e similares" },
      { key: "gorduras_boas", name: "Gorduras Boas", color: "#e67e22", display_order: 10,
        description: "Gorduras saudáveis e óleos" },
      { key: "oleaginosas", name: "Oleaginosas", color: "#d35400", display_order: 11,
        description: "Castanhas, nozes e similares" }
    ]

    categories.each do |cat|
      FoodCategory.find_or_create_by(key: cat[:key]) do |category|
        category.name = cat[:name]
        category.color = cat[:color]
        category.display_order = cat[:display_order]
        category.description = cat[:description]
      end
    end
  end
end
