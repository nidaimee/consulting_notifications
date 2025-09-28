class UpdateClientStatusEnum < ActiveRecord::Migration[8.0]
  def up
    # Permitir o novo valor 'expired'
    execute <<-SQL
      UPDATE clients#{' '}
      SET status = 'expired'#{' '}
      WHERE end_date < CURRENT_DATE AND status = 'active'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE clients#{' '}
      SET status = 'active'#{' '}
      WHERE status = 'expired'
    SQL
  end
end
