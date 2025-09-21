class AddPositionToDietFoods < ActiveRecord::Migration[8.0]
  def change
    add_column :diet_foods, :position, :integer, default: 0
    add_index :diet_foods, [ :diet_id, :position ]

    # Definir posições para registros existentes
    reversible do |dir|
      dir.up do
        Diet.find_each do |diet|
          diet.diet_foods.order(:created_at).each_with_index do |diet_food, index|
            diet_food.update_column(:position, index + 1)
          end
        end
      end
    end
  end
end
