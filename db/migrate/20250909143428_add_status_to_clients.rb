class AddStatusToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :status, :string, default: 'active', null: false

    # Definir status para registros existentes
    reversible do |dir|
      dir.up do
        # Definir todos os clientes existentes como 'active'
        execute "UPDATE clients SET status = 'active' WHERE status IS NULL"
      end
    end
  end
end
