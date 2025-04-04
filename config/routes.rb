Rails.application.routes.draw do
  # Locale-spezifische Routen
  scope "(:locale)", locale: /en|de/ do
    # Startseite
    root to: "positions#index"

    # Statische Seiten
    get "static_pages/privacy"
    get "static_pages/imprint"

    # Benutzerbezogene Routen
    get 'users/locked', to: 'users#locked', as: 'users_locked'

    # Ressourcen
    resources :positions
    resources :organizations do
      member do
        patch 'release'
        patch 'lock'
      end
    end

    # Devise-Routen
    devise_for :users, controllers: {
      registrations: "users/registrations",
      confirmations: "users/confirmations",
      sessions: 'users/sessions'
    }
  end
end