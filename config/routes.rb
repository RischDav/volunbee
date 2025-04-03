Rails.application.routes.draw do
  get "static_pages/privacy"
  get "static_pages/imprint"

  scope "(:locale)", locale: /en|de/ do
    # Deine Routen hier
    root to: "positions#index"
  end
  
  devise_for :users, controllers: {
    registrations: "users/registrations",
    confirmations: "users/confirmations",
    sessions: 'users/sessions'
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
  end

  resources :admin, only: [:index] do
    member do
      patch 'release_user'
      patch 'lock_user'
    end
  end


  get 'users/locked', to: 'users#locked', as: 'users_locked'

  get 'json_api', to: 'json_api#output'

  get "up", to: "health#up"

  root to: "positions#index"
end