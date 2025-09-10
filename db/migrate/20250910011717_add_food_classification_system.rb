# db/migrate/xxx_add_food_classification_system.rb
class AddFoodClassificationSystem < ActiveRecord::Migration[7.0]
  def change
    # Adicionar campos faltantes na tabela foods
    unless column_exists?(:foods, :portion_grams)
      add_column :foods, :portion_grams, :decimal, precision: 8, scale: 2
    end

    unless column_exists?(:foods, :portion_unit)
      add_column :foods, :portion_unit, :string, default: 'g'
    end

    # Adicionar índice na categoria se não existir
    unless index_exists?(:foods, :category)
      add_index :foods, :category
    end

    # Criar tabela de equivalências padrão para substituições
    unless table_exists?(:food_equivalences)
      create_table :food_equivalences do |t|
        t.string :category, null: false
        t.string :food_name, null: false
        t.decimal :portion_grams, precision: 8, scale: 2, null: false
        t.string :portion_unit, default: 'g'
        t.text :notes
        t.integer :display_order, default: 0

        t.timestamps
      end

      add_index :food_equivalences, :category
      add_index :food_equivalences, :food_name
      add_index :food_equivalences, [ :category, :display_order ]
    end

    # Criar tabela de categorias para melhor organização
    unless table_exists?(:food_categories)
      create_table :food_categories do |t|
        t.string :key, null: false
        t.string :name, null: false
        t.string :color
        t.text :description
        t.integer :display_order, default: 0
        t.boolean :active, default: true

        t.timestamps
      end

      add_index :food_categories, :key, unique: true
      add_index :food_categories, :display_order
    end
  end
end
