class AddNotesToDietFoods < ActiveRecord::Migration[8.0]
  def change
    add_column :diet_foods, :notes, :text
  end
end
