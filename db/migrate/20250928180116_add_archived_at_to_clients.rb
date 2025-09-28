class AddArchivedAtToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :archived_at, :datetime
    add_index :clients, :archived_at
  end
end
