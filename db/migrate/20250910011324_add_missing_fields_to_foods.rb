# db/migrate/xxx_add_missing_fields_to_foods.rb
class AddMissingFieldsToFoods < ActiveRecord::Migration[7.0]
  def change
    # Adicionar apenas campos que não existem
    unless column_exists?(:foods, :portion_grams)
      add_column :foods, :portion_grams, :decimal, precision: 8, scale: 2
    end

    unless column_exists?(:foods, :portion_unit)
      add_column :foods, :portion_unit, :string
    end

    # Índice para melhorar performance de busca por categoria
    unless index_exists?(:foods, :category)
      add_index :foods, :category
    end

    # Criar tabela de equivalências para substituições
    unless table_exists?(:food_equivalences)
      create_table :food_equivalences do |t|
        t.string :category, null: false
        t.string :food_name, null: false
        t.decimal :portion_grams, precision: 8, scale: 2, null: false
        t.string :portion_unit
        t.text :notes

        t.timestamps
      end

      add_index :food_equivalences, :category
      add_index :food_equivalences, :food_name
    end
  end
end
