module DietsHelper
  def calculate_percentage(nutrient_grams, total_calories, calories_per_gram)
    return 0 if total_calories.nil? || total_calories.zero?

    nutrient_calories = (nutrient_grams || 0) * calories_per_gram
    percentage = (nutrient_calories / total_calories * 100).round
    [ percentage, 100 ].min
  end

  def calculate_diet_calories(diet)
    diet.diet_foods.includes(:food).sum do |df|
      next 0 unless df.food && df.quantity_grams
      (df.quantity_grams * df.food.calories_per_100g) / 100.0
    end
  end

  def calculate_diet_protein(diet)
    diet.diet_foods.includes(:food).sum do |df|
      next 0 unless df.food && df.quantity_grams
      (df.quantity_grams * df.food.protein_per_100g) / 100.0
    end
  end

  def calculate_diet_carbs(diet)
    diet.diet_foods.includes(:food).sum do |df|
      next 0 unless df.food && df.quantity_grams
      (df.quantity_grams * df.food.carbs_per_100g) / 100.0
    end
  end

  def calculate_diet_fat(diet)
    diet.diet_foods.includes(:food).sum do |df|
      next 0 unless df.food && df.quantity_grams
      (df.quantity_grams * df.food.fat_per_100g) / 100.0
    end
  end

  def calculate_total_protein(diets)
    diets.sum { |diet| calculate_diet_protein(diet) }
  end

  def calculate_total_carbs(diets)
    diets.sum { |diet| calculate_diet_carbs(diet) }
  end

  def calculate_total_fat(diets)
    diets.sum { |diet| calculate_diet_fat(diet) }
  end
end
