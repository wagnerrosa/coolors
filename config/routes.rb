Rails.application.routes.draw do
  devise_for :users
  get 'colors/index'
  get 'colors/trend'

  resources :colors do
  	member do
  		get :vote_up
  	end
  end

  root 'colors#index'

  get '*path' => redirect('/') #redirect to home other pages
end
