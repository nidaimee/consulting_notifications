class AddNextUpdateAtToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :next_update_at, :date
    add_column :clients, :update_frequency_days, :integer
  end
end
