Rails.application.routes.draw do
  # Locale-spezifische Routen
  scope "(:locale)", locale: /en|de/ do
    # Startseite
    
    root to: "main#index"

    # Statische Seiten
    get "static_pages/privacy"
    get "static_pages/imprint"
    
    
    # Benutzerbezogene Routen
    get 'users/locked', to: 'users#locked', as: 'users_locked'

    #main_page
    get "positions", to: "positions#index"

    #show_positions
    get "show_positions", to: "show_positions#index"

    #matching
    get "matching", to: "matching#index"
    post 'matching/results', to: 'matching#results'
    get 'matching/results', to: 'matching#results'

    #impressum
    get "impressum", to: "impressum#index"

    # Ressourcen
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

    resources :organizations do
      member do
        patch 'release'
        patch 'lock'
      end
    end

    resources :admin, only: [:index] do
      member do
        patch 'release_user'
        patch 'lock_user'
      end
    end

    # JSON-API
    get 'json_api', to: 'json_api#output'

    # Health-Check
    get "up", to: "health#up"

    # Devise-Routen
    devise_for :users, controllers: {
      registrations: "users/registrations",
      confirmations: "users/confirmations",
      sessions: 'users/sessions'
    }
  end
end