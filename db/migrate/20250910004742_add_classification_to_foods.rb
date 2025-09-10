class AddClassificationToFoods < ActiveRecord::Migration[7.0]
  def change
    # Adicionar campos de classificação aos alimentos
    add_column :foods, :category, :string
    add_column :foods, :portion_grams, :decimal, precision: 8, scale: 2
    add_column :foods, :portion_unit, :string

    # Índice para melhorar performance de busca por categoria
    add_index :foods, :category

    # Criar tabela de equivalências para substituições
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
