class AddNextUpdateAtToClientHistories < ActiveRecord::Migration[8.0]
  def change
    add_column :client_histories, :next_update_at, :date
  end
end
