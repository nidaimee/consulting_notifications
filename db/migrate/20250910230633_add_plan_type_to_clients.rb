class AddPlanTypeToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :plan_type, :string
  end
end
