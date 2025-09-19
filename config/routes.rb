Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "sessions"
  }
  root "dashboard#index"

  get "dashboard", to: "dashboard#index"

  resources :clients do
    member do
      get :diet_pdf
    end
    resources :diets do
      member do
        post :add_food
        post :add_substitution
        delete :remove_substitution
      end
      resources :food_substitutions, only: [ :create, :destroy ]
      resources :diet_foods, only: [ :create, :destroy, :update ], path: "foods"
    end
  end

  resources :foods

  get "up" => "rails/health#show", as: :rails_health_check
end
