#!/usr/bin/env ruby

# Script para testar a funcionalidade de reordenação diretamente no Rails

puts "Testando reordenação de alimentos..."

# Simular o que o controller faz
require './config/environment'

begin
  # Buscar uma dieta para teste
  diet = Diet.includes(:diet_foods).first

  if diet.nil?
    puts "❌ Nenhuma dieta encontrada. Crie uma dieta primeiro."
    exit 1
  end

  puts "✅ Dieta encontrada: #{diet.name}"
  puts "   Alimentos na dieta: #{diet.diet_foods.count}"

  if diet.diet_foods.empty?
    puts "❌ Nenhum alimento na dieta. Adicione alguns alimentos primeiro."
    exit 1
  end

  # Mostrar ordem atual
  puts "\nOrdem atual:"
  diet.diet_foods.order(:position, :created_at).each_with_index do |df, index|
    puts "  #{index + 1}. #{df.food.name} (position: #{df.position || 'nil'})"
  end

  # Testar reordenação
  puts "\nTestando reordenação..."

  diet_foods = diet.diet_foods.order(:position, :created_at).to_a

  if diet_foods.length >= 2
    # Trocar as posições dos dois primeiros
    order_data = [
      { id: diet_foods[1].id, position: 1 },
      { id: diet_foods[0].id, position: 2 }
    ]

    puts "Aplicando nova ordem: #{order_data.inspect}"

    DietFood.transaction do
      order_data.each do |item|
        diet_food = diet.diet_foods.find(item[:id])
        diet_food.update!(position: item[:position])
        puts "  ✅ Atualizado: #{diet_food.food.name} -> posição #{item[:position]}"
      end
    end

    puts "\nNova ordem:"
    diet.reload
    diet.diet_foods.order(:position, :created_at).each_with_index do |df, index|
      puts "  #{index + 1}. #{df.food.name} (position: #{df.position})"
    end

    puts "\n✅ Teste concluído com sucesso!"
  else
    puts "❌ Precisa de pelo menos 2 alimentos para testar reordenação"
  end

rescue => e
  puts "❌ Erro: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
