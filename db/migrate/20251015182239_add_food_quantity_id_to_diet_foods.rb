class AddFoodQuantityIdToDietFoods < ActiveRecord::Migration[8.0]
  def change
    add_column :diet_foods, :food_quantity_id, :integer
  end
end
