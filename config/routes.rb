Rails.application.routes.draw do
  # Autenticação com Devise
  devise_for :users

  # Página inicial - Dashboard
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Clientes com dietas aninhadas
  resources :clients do
    member do
      get :diet_pdf
    end
    resources :diets do
      member do
        post :add_food
      end
      # Rota para remover alimento específico
      resources :diet_foods, only: [ :destroy ], path: "foods"
    end
  end

  # Alimentos
  resources :foods

  # Health check para produção
  get "up" => "rails/health#show", as: :rails_health_check
end
