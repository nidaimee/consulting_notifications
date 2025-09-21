class CreateFoodSubstitutions < ActiveRecord::Migration[8.0]
  def change
    create_table :food_substitutions do |t|
      t.references :diet_food, null: false, foreign_key: true
      t.references :substitute_food, null: false, foreign_key: { to_table: :foods }
      t.decimal :quantity_grams

      t.timestamps
    end
  end
end
