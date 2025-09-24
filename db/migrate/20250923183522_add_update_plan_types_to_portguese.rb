class AddUpdatePlanTypesToPortguese < ActiveRecord::Migration[8.0]
  def up
    # Temporariamente desabilitar callbacks para evitar problemas
    Client.reset_column_information

    # Converter dados existentes de inglês para português
    execute "UPDATE clients SET plan_type = 'mensal' WHERE plan_type = 'monthly'"
    execute "UPDATE clients SET plan_type = 'trimestral' WHERE plan_type = 'quarterly'"
    execute "UPDATE clients SET plan_type = 'semestral' WHERE plan_type = 'biannual'"
    execute "UPDATE clients SET plan_type = 'anual' WHERE plan_type = 'yearly'"

    # Também converter variações em inglês que podem existir
    execute "UPDATE clients SET plan_type = 'anual' WHERE plan_type = 'annual'"
  end

  def down
    # Reverter se necessário
    execute "UPDATE clients SET plan_type = 'monthly' WHERE plan_type = 'mensal'"
    execute "UPDATE clients SET plan_type = 'quarterly' WHERE plan_type = 'trimestral'"
    execute "UPDATE clients SET plan_type = 'biannual' WHERE plan_type = 'semestral'"
    execute "UPDATE clients SET plan_type = 'yearly' WHERE plan_type = 'anual'"
  end
end
