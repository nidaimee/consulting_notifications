class DashboardController < ApplicationController
  def index
    @clients_count = current_user.clients.count
    @active_clients = current_user.clients.where(status: "active").count
    @active_clients = current_user.clients.count
    @foods_count = current_user.foods.count
    @recent_clients = current_user.clients.order(created_at: :desc).limit(5)
    @total_revenue = current_user.clients.sum(:paid_amount)
  end
end
