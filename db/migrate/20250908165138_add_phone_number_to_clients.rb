class AddPhoneNumberToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :phone_number, :string
  end
end
