# db/seeds.rb - ALIMENTOS DA TABELA TACO BRASILEIRA
# ===============================================
# SEEDS COM DADOS REAIS DA TABELA TACO (UNICAMP)
# ===============================================

# Limpar dados existentes (cuidado em produção!)
puts "🧹 Limpando dados existentes..."
DietFood.destroy_all
Diet.destroy_all
Food.destroy_all
Client.destroy_all
User.destroy_all

# Criar nutricionista de exemplo
puts "👨‍⚕️ Criando nutricionista..."
user = User.create!(
  email: 'nutricionista@example.com',
  password: '123456',
  password_confirmation: '123456',
  name: 'Dr. Ana Silva',
  phone: '(11) 99999-9999',
  specialty: 'Nutrição Clínica',
  license_number: 'CRN-3-12345'
)

puts "✅ Nutricionista criada: #{user.name} (#{user.email})"

# ALIMENTOS BRASILEIROS - DADOS REAIS DA TABELA TACO
puts "🥗 Criando base de alimentos da Tabela TACO..."
puts "\n📁 Criando categorias de alimentos..."

categories_data = [
  { key: 'vegetais_a', name: 'Vegetais A (Livres)', color: '#27ae60', display_order: 1,
    description: 'Vegetais com baixo valor calórico, podem ser consumidos à vontade' },
  { key: 'vegetais_b', name: 'Vegetais B', color: '#16a085', display_order: 2,
    description: 'Vegetais com maior teor de carboidratos' },
  { key: 'proteina_magra', name: 'Proteínas Magras', color: '#e74c3c', display_order: 3,
    description: 'Carnes magras e fontes de proteína com baixo teor de gordura' },
  { key: 'proteina_media', name: 'Proteínas Médias', color: '#c0392b', display_order: 4,
    description: 'Proteínas com teor médio de gordura' },
  { key: 'frutas', name: 'Frutas', color: '#f39c12', display_order: 5,
    description: 'Todas as frutas frescas' },
  { key: 'laticinios', name: 'Laticínios', color: '#3498db', display_order: 6,
    description: 'Leite e derivados' },
  { key: 'carboidrato_complexo', name: 'Carboidratos Complexos', color: '#9b59b6', display_order: 7,
    description: 'Fontes de carboidratos de absorção lenta' },
  { key: 'carboidrato_simples', name: 'Carboidratos Simples', color: '#8e44ad', display_order: 8,
    description: 'Fontes de carboidratos de absorção rápida' },
  { key: 'leguminosas', name: 'Leguminosas', color: '#34495e', display_order: 9,
    description: 'Feijões, lentilhas e similares' },
  { key: 'gorduras_boas', name: 'Gorduras Boas', color: '#e67e22', display_order: 10,
    description: 'Gorduras saudáveis e óleos' },
  { key: 'oleaginosas', name: 'Oleaginosas', color: '#d35400', display_order: 11,
    description: 'Castanhas, nozes e similares' }
]
alimentos_taco = [
  # CEREAIS E DERIVADOS
  {
    name: "Arroz, integral, cozido",
    calories_per_100g: 124,
    protein_per_100g: 2.6,
    carbs_per_100g: 25.8,
    fat_per_100g: 1.0,
    category: "Cereais"
  },
  {
    name: "Arroz, polido, cozido",
    calories_per_100g: 128,
    protein_per_100g: 2.5,
    carbs_per_100g: 28.1,
    fat_per_100g: 0.1,
    category: "Cereais"
  },
  {
    name: "Aveia, flocos",
    calories_per_100g: 394,
    protein_per_100g: 13.9,
    carbs_per_100g: 66.6,
    fat_per_100g: 8.5,
    category: "Cereais"
  },
  {
    name: "Pão francês",
    calories_per_100g: 300,
    protein_per_100g: 9.4,
    carbs_per_100g: 58.6,
    fat_per_100g: 3.1,
    category: "Cereais"
  },
  {
    name: "Pão integral",
    calories_per_100g: 253,
    protein_per_100g: 9.7,
    carbs_per_100g: 43.9,
    fat_per_100g: 3.5,
    category: "Cereais"
  },
  {
    name: "Macarrão, cozido",
    calories_per_100g: 111,
    protein_per_100g: 3.7,
    carbs_per_100g: 22.2,
    fat_per_100g: 0.6,
    category: "Cereais"
  },

  # LEGUMINOSAS
  {
    name: "Feijão, carioca, cozido",
    calories_per_100g: 76,
    protein_per_100g: 4.8,
    carbs_per_100g: 13.6,
    fat_per_100g: 0.5,
    category: "Leguminosas"
  },
  {
    name: "Feijão, preto, cozido",
    calories_per_100g: 77,
    protein_per_100g: 4.5,
    carbs_per_100g: 14.0,
    fat_per_100g: 0.5,
    category: "Leguminosas"
  },
  {
    name: "Lentilha, cozida",
    calories_per_100g: 93,
    protein_per_100g: 6.3,
    carbs_per_100g: 16.3,
    fat_per_100g: 0.5,
    category: "Leguminosas"
  },
  {
    name: "Grão-de-bico, cozido",
    calories_per_100g: 164,
    protein_per_100g: 8.9,
    carbs_per_100g: 27.4,
    fat_per_100g: 2.6,
    category: "Leguminosas"
  },

  # CARNES E OVOS
  {
    name: "Frango, peito, sem pele, grelhado",
    calories_per_100g: 159,
    protein_per_100g: 32.0,
    carbs_per_100g: 0.0,
    fat_per_100g: 3.2,
    category: "Carnes"
  },
  {
    name: "Frango, coxa, com pele, assada",
    calories_per_100g: 204,
    protein_per_100g: 28.0,
    carbs_per_100g: 0.0,
    fat_per_100g: 9.7,
    category: "Carnes"
  },
  {
    name: "Carne, bovina, acém, cozida",
    calories_per_100g: 219,
    protein_per_100g: 32.2,
    carbs_per_100g: 0.0,
    fat_per_100g: 9.2,
    category: "Carnes"
  },
  {
    name: "Carne, bovina, patinho, grelhada",
    calories_per_100g: 162,
    protein_per_100g: 32.6,
    carbs_per_100g: 0.0,
    fat_per_100g: 3.4,
    category: "Carnes"
  },
  {
    name: "Ovo, galinha, inteiro, cozido",
    calories_per_100g: 146,
    protein_per_100g: 13.0,
    carbs_per_100g: 0.6,
    fat_per_100g: 9.5,
    category: "Ovos"
  },
  {
    name: "Peixe, tilápia, filé, grelhado",
    calories_per_100g: 96,
    protein_per_100g: 20.1,
    carbs_per_100g: 0.0,
    fat_per_100g: 1.7,
    category: "Peixes"
  },

  # LEITE E DERIVADOS
  {
    name: "Leite, vaca, integral",
    calories_per_100g: 61,
    protein_per_100g: 2.9,
    carbs_per_100g: 4.3,
    fat_per_100g: 3.5,
    category: "Laticínios"
  },
  {
    name: "Iogurte, natural, desnatado",
    calories_per_100g: 37,
    protein_per_100g: 4.0,
    carbs_per_100g: 4.7,
    fat_per_100g: 0.1,
    category: "Laticínios"
  },
  {
    name: "Queijo, minas, frescal",
    calories_per_100g: 264,
    protein_per_100g: 17.4,
    carbs_per_100g: 3.4,
    fat_per_100g: 20.2,
    category: "Laticínios"
  },
  {
    name: "Requeijão, cremoso",
    calories_per_100g: 270,
    protein_per_100g: 11.6,
    carbs_per_100g: 3.0,
    fat_per_100g: 23.5,
    category: "Laticínios"
  },

  # HORTALIÇAS
  {
    name: "Brócolis, cozido",
    calories_per_100g: 25,
    protein_per_100g: 3.4,
    carbs_per_100g: 4.0,
    fat_per_100g: 0.3,
    category: "Hortaliças"
  },
  {
    name: "Batata, inglesa, cozida",
    calories_per_100g: 52,
    protein_per_100g: 1.4,
    carbs_per_100g: 11.9,
    fat_per_100g: 0.1,
    category: "Hortaliças"
  },
  {
    name: "Batata-doce, cozida",
    calories_per_100g: 77,
    protein_per_100g: 1.3,
    carbs_per_100g: 18.4,
    fat_per_100g: 0.1,
    category: "Hortaliças"
  },
  {
    name: "Cenoura, crua",
    calories_per_100g: 34,
    protein_per_100g: 1.3,
    carbs_per_100g: 7.7,
    fat_per_100g: 0.2,
    category: "Hortaliças"
  },
  {
    name: "Alface, crespa",
    calories_per_100g: 15,
    protein_per_100g: 1.4,
    carbs_per_100g: 2.9,
    fat_per_100g: 0.2,
    category: "Hortaliças"
  },
  {
    name: "Tomate, maduro",
    calories_per_100g: 15,
    protein_per_100g: 1.1,
    carbs_per_100g: 3.1,
    fat_per_100g: 0.2,
    category: "Hortaliças"
  },

  # FRUTAS
  {
    name: "Banana, nanica",
    calories_per_100g: 92,
    protein_per_100g: 1.4,
    carbs_per_100g: 23.8,
    fat_per_100g: 0.1,
    category: "Frutas"
  },
  {
    name: "Maçã, Fuji, com casca",
    calories_per_100g: 56,
    protein_per_100g: 0.3,
    carbs_per_100g: 15.2,
    fat_per_100g: 0.1,
    category: "Frutas"
  },
  {
    name: "Mamão, formosa",
    calories_per_100g: 45,
    protein_per_100g: 0.8,
    carbs_per_100g: 11.6,
    fat_per_100g: 0.1,
    category: "Frutas"
  },
  {
    name: "Abacaxi, cru",
    calories_per_100g: 48,
    protein_per_100g: 0.9,
    carbs_per_100g: 12.3,
    fat_per_100g: 0.1,
    category: "Frutas"
  },
  {
    name: "Laranja, pêra",
    calories_per_100g: 37,
    protein_per_100g: 0.9,
    carbs_per_100g: 9.1,
    fat_per_100g: 0.2,
    category: "Frutas"
  },
  {
    name: "Morango",
    calories_per_100g: 30,
    protein_per_100g: 0.9,
    carbs_per_100g: 6.8,
    fat_per_100g: 0.3,
    category: "Frutas"
  },

  # ÓLEOS E GORDURAS
  {
    name: "Azeite, oliva",
    calories_per_100g: 884,
    protein_per_100g: 0.0,
    carbs_per_100g: 0.0,
    fat_per_100g: 100.0,
    category: "Óleos"
  },
  {
    name: "Óleo, soja",
    calories_per_100g: 884,
    protein_per_100g: 0.0,
    carbs_per_100g: 0.0,
    fat_per_100g: 100.0,
    category: "Óleos"
  },
  {
    name: "Manteiga, com sal",
    calories_per_100g: 760,
    protein_per_100g: 0.6,
    carbs_per_100g: 0.1,
    fat_per_100g: 84.0,
    category: "Óleos"
  },

  # NOZES E SEMENTES
  {
    name: "Castanha-do-pará",
    calories_per_100g: 643,
    protein_per_100g: 14.5,
    carbs_per_100g: 15.1,
    fat_per_100g: 63.5,
    category: "Oleaginosas"
  },
  {
    name: "Amendoim, torrado",
    calories_per_100g: 606,
    protein_per_100g: 27.2,
    carbs_per_100g: 20.3,
    fat_per_100g: 43.9,
    category: "Oleaginosas"
  },

  # BEBIDAS
  {
    name: "Café, infusão, 10%",
    calories_per_100g: 4,
    protein_per_100g: 0.1,
    carbs_per_100g: 0.8,
    fat_per_100g: 0.0,
    category: "Bebidas"
  },

  # AÇÚCARES E DOCES
  {
    name: "Açúcar, cristal",
    calories_per_100g: 387,
    protein_per_100g: 0.0,
    carbs_per_100g: 99.5,
    fat_per_100g: 0.0,
    category: "Açúcares"
  },
  {
    name: "Mel, abelha",
    calories_per_100g: 309,
    protein_per_100g: 0.4,
    carbs_per_100g: 84.4,
    fat_per_100g: 0.0,
    category: "Açúcares"
  },

  # PRATOS PREPARADOS BRASILEIROS
  {
    name: "Feijoada",
    calories_per_100g: 167,
    protein_per_100g: 8.4,
    carbs_per_100g: 12.5,
    fat_per_100g: 8.8,
    category: "Pratos Preparados"
  },
  {
    name: "Farofa, mandioca",
    calories_per_100g: 365,
    protein_per_100g: 1.8,
    carbs_per_100g: 57.7,
    fat_per_100g: 13.8,
    category: "Pratos Preparados"
  }
]

# Criar alimentos no banco
alimentos_taco.each do |alimento_data|
  user.foods.create!(alimento_data)
  print "."
end

puts "\n✅ #{user.foods.count} alimentos da Tabela TACO criados!"

# Mostrar estatísticas por categoria
puts "\n📊 Alimentos criados por categoria:"
user.foods.group(:category).count.each do |categoria, quantidade|
  puts "  #{categoria}: #{quantidade} alimentos"
end

# Criar cliente de exemplo
puts "\n👤 Criando cliente de exemplo..."
client = user.clients.create!(
  name: 'João Santos',
  phone_number: '(11) 98888-8888',
  start_date: Date.today,
  end_date: Date.today + 60.days,
  paid_amount: 450.00,
  status: 'active',
  note: 'Cliente quer perder 10kg e melhorar a alimentação. Gosta muito de arroz e feijão.'
)

puts "✅ Cliente criado: #{client.name}"

# Criar algumas dietas de exemplo
puts "\n🍽️ Criando dietas de exemplo..."

# Café da Manhã
breakfast = user.diets.create!(
  client: client,
  name: 'Café da Manhã',
  meal_type: 'breakfast',
  created_date: Date.today,
  notes: 'Café da manhã nutritivo e balanceado'
)

# Adicionar alimentos ao café da manhã
aveia = user.foods.find_by(name: "Aveia, flocos")
banana = user.foods.find_by(name: "Banana, nanica")
leite = user.foods.find_by(name: "Leite, vaca, integral")

if aveia && banana && leite
  breakfast.diet_foods.create!(food: aveia, quantity_grams: 30)    # 30g de aveia
  breakfast.diet_foods.create!(food: banana, quantity_grams: 100)  # 1 banana média
  breakfast.diet_foods.create!(food: leite, quantity_grams: 200)   # 1 copo de leite
end

# Almoço
lunch = user.diets.create!(
  client: client,
  name: 'Almoço',
  meal_type: 'lunch',
  created_date: Date.today,
  notes: 'Almoço tradicional brasileiro'
)

# Adicionar alimentos ao almoço
arroz = user.foods.find_by(name: "Arroz, polido, cozido")
feijao = user.foods.find_by(name: "Feijão, carioca, cozido")
frango = user.foods.find_by(name: "Frango, peito, sem pele, grelhado")
brocolis = user.foods.find_by(name: "Brócolis, cozido")

if arroz && feijao && frango && brocolis
  lunch.diet_foods.create!(food: arroz, quantity_grams: 150)     # 150g de arroz
  lunch.diet_foods.create!(food: feijao, quantity_grams: 100)   # 100g de feijão
  lunch.diet_foods.create!(food: frango, quantity_grams: 120)   # 120g de frango
  lunch.diet_foods.create!(food: brocolis, quantity_grams: 80)  # 80g de brócolis
end

puts "✅ Dietas de exemplo criadas:"
puts "  - #{breakfast.name}: #{breakfast.total_calories.round(1)} kcal"
puts "  - #{lunch.name}: #{lunch.total_calories.round(1)} kcal"

puts "\n🎉 SEEDS COMPLETO COM TABELA TACO!"
puts "📧 Login: #{user.email}"
puts "🔑 Senha: 123456"
puts "🥗 #{user.foods.count} alimentos brasileiros disponíveis"
puts "👤 #{user.clients.count} cliente de exemplo"
puts "🍽️ #{user.diets.count} dietas de exemplo"
puts "\n🎯 Acesse: http://localhost:3000 e teste o sistema!"
