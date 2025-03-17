Rails.application.routes.draw do
  get "static_pages/privacy"
  get "static_pages/imprint"
  devise_for :users, controllers: {
    registrations: "users/registrations",
    confirmations: "users/confirmations"
  }

  resources :organizations do
    member do
      patch 'release'
      patch 'lock'
    end
  end


  resources :positions do
    member do
      patch 'release'
      patch 'lock'
      patch 'online'
      patch 'offline'
      delete 'delete_picture/:picture_type', to: 'positions#delete_picture', as: 'delete_picture'
    end
    collection do
      get 'json_output', to: 'positions#json_output'
    end
  end

  resources :admin, only: [:index] do
    member do
      patch 'release_user'
      patch 'lock_user'
    end
  end

  get 'users/locked', to: 'users#locked', as: 'user_locked'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up", to: "health#up"
  root to: "positions#index"
end