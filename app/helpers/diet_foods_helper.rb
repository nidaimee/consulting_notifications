module DietFoodsHelper
  def diet_food_quantity_label(diet_food)
    fq = diet_food.food_quantity
    if fq.present? && diet_food.quantity.present?
      grams = (diet_food.quantity.to_f * fq.grams.to_f).round(1)
      "#{diet_food.quantity.to_f} #{fq.name}#{'s' if diet_food.quantity.to_f > 1} (#{grams}g)"
    elsif diet_food.quantity_grams.present?
      "#{diet_food.quantity_grams.to_f.round(1)}g"
    else
      "-"
    end
  end
end
