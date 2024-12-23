Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  get "organization", to: "organizations#index", as: :organization_index
  resource :organization, only: [ :edit, :update ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up", to: "health#up"
  get "positions", to: "positions#index"
  root to: "positions#index"

  # Defines the root path route ("/")
end
