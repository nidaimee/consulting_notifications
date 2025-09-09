class AddUserToDiets < ActiveRecord::Migration[8.0]
  def change
    add_reference :diets, :user, null: false, foreign_key: true
  end
end
