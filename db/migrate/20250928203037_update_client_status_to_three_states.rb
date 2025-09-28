class UpdateClientStatusToThreeStates < ActiveRecord::Migration[8.0]
  def up
    # Atualizar clientes existentes baseado nas datas
    Client.where(archived_at: nil).find_each do |client|
      next unless client.end_date.present?

      days_remaining = (client.end_date - Date.current).to_i

      new_status = case days_remaining
      when ...-1
                    'expired'
      when 0..7
                    'expiring'
      else
                    'active'
      end

      client.update_column(:status, new_status)
    end
  end

  def down
    # Reverter todos para active
    execute <<-SQL
      UPDATE clients#{' '}
      SET status = 'active'#{' '}
      WHERE status IN ('expired', 'expiring')
    SQL
  end
end
