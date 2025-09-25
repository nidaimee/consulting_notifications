Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "sessions",
    registrations: "registrations"
  }
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  resources :clients do
    # Rota para reordenar dietas do cliente (drag & drop nos cards)
    post "reorder_diets", to: "diets#reorder", as: :reorder_diets

    member do
      patch :update_note
      get :diet_pdf
      patch :add_photos
      delete "remove_photo/:photo_id", to: "clients#remove_photo", as: :remove_photo
      patch "replace_photo/:photo_id", to: "clients#replace_photo", as: :replace_photo
      get :download_comparison
      get :serve_image
    end

    resources :client_histories, only: [ :create, :destroy, :update, :edit ], path: "historico" do
      member do
        delete "remove_photo/:photo_id", to: "client_histories#remove_photo", as: :remove_history_photo
        patch "replace_photo/:photo_id", to: "client_histories#replace_photo", as: :replace_history_photo
      end
    end

    resources :diets do
      post "duplicate", on: :member
      post "move_up", on: :member
      post "move_down", on: :member

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
