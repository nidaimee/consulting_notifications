Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "sessions",
    registrations: "registrations"
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
        patch :reorder_foods
      end
      resources :food_substitutions, only: [ :create, :update, :destroy ]
      resources :diet_foods, only: [ :create, :destroy, :update ], path: "foods" do
        member do
          patch :move_up
          patch :move_down
        end
      end
    end
  end

  resources :foods

  get "up" => "rails/health#show", as: :rails_health_check
end
