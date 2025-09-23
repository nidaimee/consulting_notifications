# db/seeds.rb - ALIMENTOS DA TABELA TACO BRASILEIRA
# ===============================================
# SEEDS COM DADOS REAIS DA TABELA TACO (UNICAMP)
# ===============================================

# Limpar dados existentes (cuidado em produção!)
puts "🧹 Limpando dados existentes..."
FoodSubstitution.destroy_all
DietFood.destroy_all
Diet.destroy_all
Food.destroy_all
Client.destroy_all
User.destroy_all

# Criar nutricionistas
puts "👨‍⚕️ Criando nutricionistas..."

users = []

user1 = User.create!(
  email: 'nutricionista@example.com',
  password: '123456',
  password_confirmation: '123456',
  name: 'Dr. Ana Silva',
  phone: '(11) 99999-9999',
  specialty: 'Nutrição Clínica',
  license_number: 'CRN-3-12345'
)
users << user1

user2 = User.create!(
  email: 'felipe@teste.com',
  password: '123456',
  password_confirmation: '123456',
  name: 'Felipe',
  phone: '(11) 99999-9999',
  specialty: 'Nutrição Esportiva',
  license_number: 'CRN-3-67890'
)
users << user2

user3 = User.create!(
  email: 'maria@nutri.com',
  password: '123456',
  password_confirmation: '123456',
  name: 'Maria Oliveira',
  phone: '(11) 98888-8888',
  specialty: 'Nutrição Funcional',
  license_number: 'CRN-3-54321'
)
users << user3

user4 = User.create!(
  email: 'raphael@nutri.com',
  password: '123456',
  password_confirmation: '123456',
  name: 'Raphael',
  phone: '(11) 98888-8888',
  specialty: 'Nutrição Funcional',
  license_number: 'CRN-3-54321'
)
users << user4

puts "✅ #{users.count} nutricionistas criados!"
users.each { |u| puts "  - #{u.name} (#{u.email})" }

# ALIMENTOS BRASILEIROS - DADOS REAIS DA TABELA TACO
puts "\n🥗 Criando base de alimentos da Tabela TACO..."

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
  {
    name: "Quinoa, cozida",
    calories_per_100g: 120,
    protein_per_100g: 4.4,
    carbs_per_100g: 21.3,
    fat_per_100g: 1.9,
    category: "Cereais"
  },
  {
    name: "Tapioca",
    calories_per_100g: 358,
    protein_per_100g: 0.5,
    carbs_per_100g: 88.7,
    fat_per_100g: 0.2,
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
  {
    name: "Ervilha, cozida",
    calories_per_100g: 81,
    protein_per_100g: 5.4,
    carbs_per_100g: 14.5,
    fat_per_100g: 0.4,
    category: "Leguminosas"
  },
  {
    name: "Soja, cozida",
    calories_per_100g: 172,
    protein_per_100g: 16.6,
    carbs_per_100g: 9.9,
    fat_per_100g: 9.0,
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
    name: "Carne, bovina, acém, cozido",
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
    name: "Carne, bovina, contrafilé, grelhado",
    calories_per_100g: 206,
    protein_per_100g: 31.9,
    carbs_per_100g: 0.0,
    fat_per_100g: 8.3,
    category: "Carnes"
  },
  {
    name: "Carne, suína, lombo, assado",
    calories_per_100g: 196,
    protein_per_100g: 32.1,
    carbs_per_100g: 0.0,
    fat_per_100g: 6.7,
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
    name: "Ovo, galinha, clara, cozida",
    calories_per_100g: 59,
    protein_per_100g: 13.0,
    carbs_per_100g: 0.0,
    fat_per_100g: 0.1,
    category: "Ovos"
  },

  # PEIXES E FRUTOS DO MAR
  {
    name: "Peixe, tilápia, filé, grelhado",
    calories_per_100g: 96,
    protein_per_100g: 20.1,
    carbs_per_100g: 0.0,
    fat_per_100g: 1.7,
    category: "Peixes"
  },
  {
    name: "Salmão, grelhado",
    calories_per_100g: 208,
    protein_per_100g: 22.5,
    carbs_per_100g: 0.0,
    fat_per_100g: 12.5,
    category: "Peixes"
  },
  {
    name: "Atum, conserva em água",
    calories_per_100g: 116,
    protein_per_100g: 25.5,
    carbs_per_100g: 0.0,
    fat_per_100g: 1.3,
    category: "Peixes"
  },
  {
    name: "Camarão, cozido",
    calories_per_100g: 99,
    protein_per_100g: 20.9,
    carbs_per_100g: 0.0,
    fat_per_100g: 1.7,
    category: "Frutos do Mar"
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
    name: "Leite, vaca, desnatado",
    calories_per_100g: 34,
    protein_per_100g: 3.4,
    carbs_per_100g: 5.0,
    fat_per_100g: 0.1,
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
    name: "Iogurte, natural, integral",
    calories_per_100g: 61,
    protein_per_100g: 3.5,
    carbs_per_100g: 4.7,
    fat_per_100g: 3.3,
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
    name: "Queijo, muçarela",
    calories_per_100g: 330,
    protein_per_100g: 22.6,
    carbs_per_100g: 3.0,
    fat_per_100g: 25.2,
    category: "Laticínios"
  },
  {
    name: "Queijo, cottage",
    calories_per_100g: 103,
    protein_per_100g: 11.0,
    carbs_per_100g: 3.4,
    fat_per_100g: 4.3,
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

  # HORTALIÇAS - GRUPO A (BAIXO VALOR CALÓRICO)
  {
    name: "Alface, crespa",
    calories_per_100g: 15,
    protein_per_100g: 1.4,
    carbs_per_100g: 2.9,
    fat_per_100g: 0.2,
    category: "Vegetais A"
  },
  {
    name: "Rúcula",
    calories_per_100g: 25,
    protein_per_100g: 2.6,
    carbs_per_100g: 3.7,
    fat_per_100g: 0.7,
    category: "Vegetais A"
  },
  {
    name: "Espinafre, cozido",
    calories_per_100g: 23,
    protein_per_100g: 2.9,
    carbs_per_100g: 3.6,
    fat_per_100g: 0.4,
    category: "Vegetais A"
  },
  {
    name: "Couve, refogada",
    calories_per_100g: 90,
    protein_per_100g: 1.7,
    carbs_per_100g: 8.7,
    fat_per_100g: 6.6,
    category: "Vegetais A"
  },
  {
    name: "Brócolis, cozido",
    calories_per_100g: 25,
    protein_per_100g: 3.4,
    carbs_per_100g: 4.0,
    fat_per_100g: 0.3,
    category: "Vegetais A"
  },
  {
    name: "Couve-flor, cozida",
    calories_per_100g: 23,
    protein_per_100g: 1.9,
    carbs_per_100g: 4.5,
    fat_per_100g: 0.3,
    category: "Vegetais A"
  },
  {
    name: "Pepino",
    calories_per_100g: 16,
    protein_per_100g: 0.7,
    carbs_per_100g: 3.6,
    fat_per_100g: 0.1,
    category: "Vegetais A"
  },
  {
    name: "Tomate, maduro",
    calories_per_100g: 15,
    protein_per_100g: 1.1,
    carbs_per_100g: 3.1,
    fat_per_100g: 0.2,
    category: "Vegetais A"
  },
  {
    name: "Abobrinha, cozida",
    calories_per_100g: 20,
    protein_per_100g: 1.2,
    carbs_per_100g: 4.2,
    fat_per_100g: 0.2,
    category: "Vegetais A"
  },
  {
    name: "Berinjela, cozida",
    calories_per_100g: 20,
    protein_per_100g: 0.8,
    carbs_per_100g: 4.4,
    fat_per_100g: 0.2,
    category: "Vegetais A"
  },

  # HORTALIÇAS - GRUPO B (MAIOR TEOR DE CARBOIDRATOS)
  {
    name: "Batata, inglesa, cozida",
    calories_per_100g: 52,
    protein_per_100g: 1.4,
    carbs_per_100g: 11.9,
    fat_per_100g: 0.1,
    category: "Vegetais B"
  },
  {
    name: "Batata-doce, cozida",
    calories_per_100g: 77,
    protein_per_100g: 1.3,
    carbs_per_100g: 18.4,
    fat_per_100g: 0.1,
    category: "Vegetais B"
  },
  {
    name: "Mandioca, cozida",
    calories_per_100g: 125,
    protein_per_100g: 0.6,
    carbs_per_100g: 30.1,
    fat_per_100g: 0.3,
    category: "Vegetais B"
  },
  {
    name: "Inhame, cozido",
    calories_per_100g: 116,
    protein_per_100g: 1.5,
    carbs_per_100g: 27.6,
    fat_per_100g: 0.2,
    category: "Vegetais B"
  },
  {
    name: "Cenoura, crua",
    calories_per_100g: 34,
    protein_per_100g: 1.3,
    carbs_per_100g: 7.7,
    fat_per_100g: 0.2,
    category: "Vegetais B"
  },
  {
    name: "Beterraba, cozida",
    calories_per_100g: 49,
    protein_per_100g: 1.9,
    carbs_per_100g: 11.1,
    fat_per_100g: 0.1,
    category: "Vegetais B"
  },
  {
    name: "Abóbora, cozida",
    calories_per_100g: 40,
    protein_per_100g: 1.4,
    carbs_per_100g: 9.5,
    fat_per_100g: 0.3,
    category: "Vegetais B"
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
  {
    name: "Manga, Palmer",
    calories_per_100g: 72,
    protein_per_100g: 0.4,
    carbs_per_100g: 19.4,
    fat_per_100g: 0.2,
    category: "Frutas"
  },
  {
    name: "Uva, roxa",
    calories_per_100g: 49,
    protein_per_100g: 0.7,
    carbs_per_100g: 12.7,
    fat_per_100g: 0.2,
    category: "Frutas"
  },
  {
    name: "Melancia",
    calories_per_100g: 33,
    protein_per_100g: 0.9,
    carbs_per_100g: 8.1,
    fat_per_100g: 0.1,
    category: "Frutas"
  },
  {
    name: "Pêra, Williams",
    calories_per_100g: 53,
    protein_per_100g: 0.3,
    carbs_per_100g: 14.0,
    fat_per_100g: 0.1,
    category: "Frutas"
  },
  {
    name: "Kiwi",
    calories_per_100g: 51,
    protein_per_100g: 1.3,
    carbs_per_100g: 11.5,
    fat_per_100g: 0.6,
    category: "Frutas"
  },
  {
    name: "Abacate",
    calories_per_100g: 96,
    protein_per_100g: 1.2,
    carbs_per_100g: 6.0,
    fat_per_100g: 8.4,
    category: "Frutas"
  },

  # ÓLEOS E GORDURAS
  {
    name: "Azeite, oliva, extra virgem",
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
    name: "Óleo, coco",
    calories_per_100g: 872,
    protein_per_100g: 0.0,
    carbs_per_100g: 0.0,
    fat_per_100g: 99.0,
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

  # OLEAGINOSAS E SEMENTES
  {
    name: "Castanha-do-pará",
    calories_per_100g: 643,
    protein_per_100g: 14.5,
    carbs_per_100g: 15.1,
    fat_per_100g: 63.5,
    category: "Oleaginosas"
  },
  {
    name: "Castanha de caju, torrada",
    calories_per_100g: 570,
    protein_per_100g: 18.5,
    carbs_per_100g: 29.1,
    fat_per_100g: 46.3,
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
  {
    name: "Nozes",
    calories_per_100g: 651,
    protein_per_100g: 14.3,
    carbs_per_100g: 13.7,
    fat_per_100g: 65.2,
    category: "Oleaginosas"
  },
  {
    name: "Amêndoas",
    calories_per_100g: 581,
    protein_per_100g: 21.2,
    carbs_per_100g: 21.6,
    fat_per_100g: 50.6,
    category: "Oleaginosas"
  },
  {
    name: "Chia, sementes",
    calories_per_100g: 486,
    protein_per_100g: 16.5,
    carbs_per_100g: 42.1,
    fat_per_100g: 30.7,
    category: "Oleaginosas"
  },
  {
    name: "Linhaça, semente",
    calories_per_100g: 495,
    protein_per_100g: 14.1,
    carbs_per_100g: 43.3,
    fat_per_100g: 32.3,
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
  {
    name: "Chá, mate, infusão",
    calories_per_100g: 3,
    protein_per_100g: 0.0,
    carbs_per_100g: 0.6,
    fat_per_100g: 0.0,
    category: "Bebidas"
  },
  {
    name: "Água de coco",
    calories_per_100g: 22,
    protein_per_100g: 0.3,
    carbs_per_100g: 5.3,
    fat_per_100g: 0.1,
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
    name: "Açúcar, mascavo",
    calories_per_100g: 369,
    protein_per_100g: 0.8,
    carbs_per_100g: 94.0,
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
  },
  {
    name: "Açaí, polpa",
    calories_per_100g: 58,
    protein_per_100g: 0.8,
    carbs_per_100g: 6.2,
    fat_per_100g: 3.9,
    category: "Frutas"
  }
]

# Criar alimentos para TODOS os usuários
puts "\nCriando alimentos para cada nutricionista..."
users.each do |user|
  print "\n  #{user.name}: "
  alimentos_taco.each do |alimento_data|
    user.foods.create!(alimento_data)
    print "."
  end
  puts " ✅ #{user.foods.count} alimentos criados!"
end

# Estatísticas gerais
puts "\n📊 Estatísticas Gerais:"
puts "  Total de alimentos únicos: #{alimentos_taco.count}"
puts "  Total de alimentos no banco: #{Food.count}"
puts "  Alimentos por usuário: #{Food.count / User.count}"

# Mostrar distribuição por categoria para o primeiro usuário
puts "\n📊 Categorias de alimentos disponíveis:"
users.first.foods.group(:category).count.each do |categoria, quantidade|
  puts "  #{categoria}: #{quantidade} alimentos"
end

# Criar cliente de exemplo para cada nutricionista
puts "\n👤 Criando clientes de exemplo..."

# Cliente para
