Rails.application.routes.draw do
  devise_for :users
  resources :colors do
  	member do
  		put "like", to: "colors#upvote"
  	end
  end
  get 'colors/index'
  root 'colors#index'

  get '*path' => redirect('/') #redirect to home other pages
end
