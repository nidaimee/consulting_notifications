Rails.application.routes.draw do
  devise_for :users
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
      resources :diet_foods, only: [ :destroy ], path: "foods"
    end
  end

  resources :foods

  get "up" => "rails/health#show", as: :rails_health_check
end
