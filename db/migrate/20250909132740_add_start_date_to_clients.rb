class AddStartDateToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :start_date, :date
  end
end
