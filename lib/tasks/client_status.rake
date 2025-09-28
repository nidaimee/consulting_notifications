namespace :clients do
  desc "Update client status based on remaining days"
  task update_status: :environment do
    puts "🔄 Atualizando status dos clientes..."

    updated_count = 0
    Client.where(archived_at: nil).includes(:user).find_each do |client|
      next unless client.end_date.present?

      old_status = client.status
      new_status = client.automatic_status

      if old_status != new_status
        client.update_column(:status, new_status)
        puts "👤 #{client.name}: #{old_status} → #{new_status} (#{client.days_remaining} dias)"
        updated_count += 1
      end
    end

    puts "✅ #{updated_count} clientes atualizados!"

    # Estatísticas
    active_count = Client.active.count
    expiring_count = Client.expiring.count
    expired_count = Client.expired.count

    puts "\n📊 Status atual:"
    puts "   🟢 Ativos: #{active_count}"
    puts "   🟡 Expirando: #{expiring_count}"
    puts "   🔴 Expirados: #{expired_count}"
  end
end
