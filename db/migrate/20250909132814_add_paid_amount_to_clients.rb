class AddPaidAmountToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :paid_amount, :decimal
  end
end
