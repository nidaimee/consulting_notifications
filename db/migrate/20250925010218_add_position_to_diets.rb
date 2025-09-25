class AddPositionToDiets < ActiveRecord::Migration[8.0]
  def change
    add_column :diets, :position, :integer
  end
end
