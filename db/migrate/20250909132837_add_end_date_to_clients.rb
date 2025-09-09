class AddEndDateToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :end_date, :date
  end
end
