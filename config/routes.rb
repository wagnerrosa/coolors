Rails.application.routes.draw do
  devise_for :users

  resources :colors do
    member do
      post :vote_up
    end
    collection do
      get :trend
    end
  end

  # Render health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "colors#index"
end
