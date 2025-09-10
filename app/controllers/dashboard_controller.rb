class DashboardController < ApplicationController
  def index
    @clients_count = current_user.clients.count
    @active_clients = current_user.clients.where(status: 'active').count
    @foods_count = current_user.foods.count
    @recent_clients = current_user.clients.order(created_at: :desc).limit(5)
    @total_revenue = current_user.clients.sum(:paid_amount)
  end

  # Vista do plano diário completo - como sua imagem de referência
  def daily_plan
    @client = current_user.clients.find(params[:client_id])
    @diets = @client.diets.includes(:diet_foods, :foods).order(:meal_type)
    
    # Organizar por tipo de refeição
    @meal_types = [
      'breakfast', 'morning_snack', 'lunch', 
      'afternoon_snack', 'dinner', 'supper'
    ]
    
    @organized_diets = @meal_types.map do |meal_type|
      diet = @diets.find { |d| d.meal_type == meal_type }
      {
        name: meal_type_name(meal_type),
        time: meal_type_time(meal_type),
        diet: diet
      }
    end
    
    @daily_totals = calculate_daily_totals(@diets)
  end

  private

  def meal_type_name(meal_type)
    names = {
      'breakfast' => 'Café da Manhã',
      'morning_snack' => 'Lanche da Manhã', 
      'lunch' => 'Almoço',
      'afternoon_snack' => 'Lanche da Tarde',
      'dinner' => 'Jantar',
      'supper' => 'Ceia'
    }
    names[meal_type] || meal_type.humanize
  end

  def meal_type_time(meal_type)
    times = {
      'breakfast' => '8:00',
      'morning_snack' => '10:00',
      'lunch' => '12:00', 
      'afternoon_snack' => '15:00',
      'dinner' => '19:00',
      'supper' => '22:00'
    }
    times[meal_type] || '0:00'
  end

  def calculate_daily_totals(diets)
    {
      calories: diets.sum(&:total_calories),
      protein: diets.sum(&:total_protein),
      carbs: diets.sum(&:total_carbs),
      fat: diets.sum(&:total_fat)
    }
  end
end
