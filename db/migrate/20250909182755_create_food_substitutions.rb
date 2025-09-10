class CreateFoodSubstitutions < ActiveRecord::Migration[7.0]
  def change
    create_table :food_substitutions do |t|
      t.bigint :diet_food_id, null: false
      t.bigint :substitute_food_id, null: false
      t.decimal :quantity_grams, precision: 8, scale: 2, null: false
      t.text :notes

      t.timestamps
    end

    # Adicionar foreign keys manualmente
    add_foreign_key :food_substitutions, :diet_foods, column: :diet_food_id
    add_foreign_key :food_substitutions, :foods, column: :substitute_food_id

    # Adicionar índices
    add_index :food_substitutions, :diet_food_id
    add_index :food_substitutions, :substitute_food_id
  end
end
