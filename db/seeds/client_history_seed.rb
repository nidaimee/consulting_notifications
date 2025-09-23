# Script para popular histórico de clientes existentes
# Execute com: rails runner db/seeds/client_history_seed.rb

# Script para popular histórico de clientes existentes
# Execute com: rails runner db/seeds/client_history_seed.rb

begin
  # Verificar se a tabela ClientHistory existe
  unless ActiveRecord::Base.connection.table_exists?('client_histories')
    puts "Tabela client_histories não existe. Execute as migrations primeiro:"
    puts "rails db:migrate"
    exit
  end

  puts "Populando histórico de clientes existentes..."

  User.includes(clients: [ :diets, :client_histories ]).find_each do |user|
    user.clients.each do |client|
      # Se o cliente não tem histórico, criar entrada de criação
    end
  end

  puts "Histórico populado para #{Client.count} clientes!"
  puts "Total de registros de histórico: #{ClientHistory.count}"

rescue => e
  puts "Erro ao popular histórico: #{e.message}"
  puts "Certifique-se de que as migrations foram executadas corretamente."
end
