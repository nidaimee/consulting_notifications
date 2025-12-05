class AddQuantityToDietFoods < ActiveRecord::Migration[8.0]
  def change
    add_column :diet_foods, :quantity, :integer, default: 1, null: false
  end
end
