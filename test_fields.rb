#!/usr/bin/env ruby

# Script para testar se os campos do DietFood estão funcionando corretamente
puts "Testando campos do modelo DietFood..."

# Carrega o ambiente Rails
require_relative 'config/environment'

# Verifica se existem registros DietFood
diet_food_count = DietFood.count
puts "Total de DietFood registros: #{diet_food_count}"

if diet_food_count > 0
  diet_food = DietFood.first
  puts "\nTestando primeiro registro DietFood (ID: #{diet_food.id}):"

  # Testa os campos principais
  begin
    puts "- quantity_grams: #{diet_food.quantity_grams}"
    puts "- calculated_calories: #{diet_food.calculated_calories}"
    puts "- calculated_protein: #{diet_food.calculated_protein}"
    puts "- calculated_carbs: #{diet_food.calculated_carbs}"
    puts "- calculated_fat: #{diet_food.calculated_fat}"
    puts "- nutrition_summary: #{diet_food.nutrition_summary}"
    puts "\n✅ Todos os campos estão funcionando corretamente!"
  rescue => e
    puts "\n❌ Erro ao acessar campos: #{e.message}"
    puts "Backtrace: #{e.backtrace.first(3).join("\n")}"
  end
else
  puts "❌ Nenhum registro DietFood encontrado para testar."
end

puts "\nTeste concluído!"
