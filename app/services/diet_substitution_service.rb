class DietSubstitutionService
  def initialize(diets)
    @diets = diets
    @substitutions = {}
  end

  def generate_substitution_tables
    collect_foods_by_category
    build_substitution_tables
    @substitutions
  end

  private

  def collect_foods_by_category
    @categorized_foods = {}

    @diets.each do |diet|
      diet.diet_foods.includes(food: :food_category).each do |diet_food|
        next unless diet_food.food.has_category?

        category_key = diet_food.food.category
        @categorized_foods[category_key] ||= {}

        food_id = diet_food.food.id

        # Se o alimento já existe, pega a maior quantidade
        if @categorized_foods[category_key][food_id]
          current_qty = @categorized_foods[category_key][food_id][:quantity]
          @categorized_foods[category_key][food_id][:quantity] = [ current_qty, diet_food.quantity_grams ].max
        else
          @categorized_foods[category_key][food_id] = {
            food: diet_food.food,
            quantity: diet_food.quantity_grams
          }
        end
      end
    end
  end

  def build_substitution_tables
    @categorized_foods.each do |category_key, foods|
      category = FoodCategory.find_by(key: category_key)
      next unless category

      @substitutions[category_key] = {
        category_name: category.name,
        category_color: category.color,
        foods: build_food_substitutions(foods)
      }
    end

    # Ordenar por display_order das categorias
    @substitutions = @substitutions.sort_by do |key, data|
      FoodCategory.find_by(key: key)&.display_order || 999
    end.to_h
  end

  def build_food_substitutions(foods)
    foods.map do |food_id, food_data|
      food = food_data[:food]
      quantity = food_data[:quantity]

      {
        name: food.name,
        quantity: quantity,
        portions: food.calculate_portions(quantity),
        substitutes: calculate_substitutes(food, quantity)
      }
    end
  end

  def calculate_substitutes(food, quantity)
    # Busca as equivalências da categoria
    equivalences = FoodEquivalence.by_category(food.category).ordered

    return [] if equivalences.empty? || !food.portion_grams

    portions = food.calculate_portions(quantity)

    equivalences.map do |equiv|
      {
        name: equiv.food_name,
        quantity: (portions * equiv.portion_grams).round,
        unit: equiv.portion_unit || "g"
      }
    end.reject { |s| s[:name].downcase == food.name.downcase }
  end
end

# app/helpers/diet_pdf_helper.rb
module DietPdfHelper
  def generate_substitution_tables(diets)
    service = DietSubstitutionService.new(diets)
    service.generate_substitution_tables
  end

  def format_food_quantity(quantity, unit = "g")
    "#{quantity.to_i}#{unit}"
  end

  def category_badge_color(category_key)
    category = FoodCategory.find_by(key: category_key)
    category&.color || "#95a5a6"
  end
end
