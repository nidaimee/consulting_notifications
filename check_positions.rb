#!/usr/bin/env ruby

# Script para verificar posições dos alimentos nas dietas

puts "Verificando posições dos alimentos nas dietas..."

require './config/environment'

Diet.includes(diet_foods: :food).each do |diet|
  puts "\n=== Dieta: #{diet.name} (ID: #{diet.id}) ==="

  diet_foods = diet.diet_foods.includes(:food).order(:position, :created_at)

  if diet_foods.empty?
    puts "  Nenhum alimento"
    next
  end

  puts "  Ordem atual no banco:"
  diet_foods.each_with_index do |df, index|
    puts "    #{index + 1}. #{df.food.name} (position: #{df.position || 'nil'}, id: #{df.id})"
  end

  # Verificar se há posições nil ou duplicadas
  positions = diet_foods.map(&:position).compact
  nil_positions = diet_foods.select { |df| df.position.nil? }

  if nil_positions.any?
    puts "  ⚠️  PROBLEMA: #{nil_positions.count} alimentos sem posição definida"

    puts "  🔧 Corrigindo posições..."
    diet_foods.each_with_index do |df, index|
      new_position = index + 1
      if df.position != new_position
        df.update!(position: new_position)
        puts "    ✅ #{df.food.name}: position #{df.position} → #{new_position}"
      end
    end
  end

  if positions.uniq.length != positions.length
    puts "  ⚠️  PROBLEMA: Posições duplicadas encontradas"
  end
end

puts "\n✅ Verificação concluída!"
