class CreateFoodQuantities < ActiveRecord::Migration[7.0]
  def change
    create_table :food_quantities do |t|
      t.references :food, null: false, foreign_key: true
      t.string :name
      t.float :grams
      t.timestamps
    end
  end
end
