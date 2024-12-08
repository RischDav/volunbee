Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "health#up"
  get "organization", to: "organization#index", as: :organization
  get "positions", to: "positions#index"
  root to: "positions#index"

  # Defines the root path route ("/")
end
