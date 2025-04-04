Rails.application.routes.draw do
  get "static_pages/privacy"
  get "static_pages/imprint"

  # Locale-spezifische Routen
  scope "(:locale)", locale: /en|de/ do
    root to: "positions#index" # Definiert die Startseite mit optionaler Locale
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
end