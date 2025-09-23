class CreateClientHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :client_histories do |t|
      t.references :client, null: false, foreign_key: true
      t.string :action, null: false
      t.text :description
      t.json :metadata

      t.timestamps
    end

    add_index :client_histories, [ :client_id, :created_at ]
    add_index :client_histories, :action
  end
end
