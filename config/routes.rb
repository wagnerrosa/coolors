Rails.application.routes.draw do
  resources :colors
  get 'colors/index'
  root 'colors#index'
end
