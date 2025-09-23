class AddFieldsToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :age, :integer
    add_column :clients, :sex, :string
    add_column :clients, :height, :float
  end
end
