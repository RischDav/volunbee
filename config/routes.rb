Rails.application.routes.draw do
  # Locale-spezifische Routen
  scope "(:locale)", locale: /en|de/ do
    # Startseite
    root to: "main#index"

    # Statische Seiten
    get "static_pages/privacy"
    get "static_pages/imprint"
    get 'position-submitted', to: 'static_pages#position_submitted', as: 'position_submitted'
    get 'neue-freizeitposition', to: 'static_pages#new_freetime_position', as: 'new_freetime_position'
    post 'freetime-position', to: 'static_pages#create_freetime_position', as: 'create_freetime_position'
    get 'freetime-position/success', to: 'static_pages#success_freetime_position', as: 'success_freetime_position'
    get 'neues-ehrenamt', to: 'static_pages#new_volunteering_position', as: 'new_volunteering_position'
    post 'volunteering-position', to: 'static_pages#create_volunteering_position', as: 'create_volunteering_position'
    get 'volunteering-position/success', to: 'static_pages#success_volunteering_position', as: 'success_volunteering_position'
    
    
    # Benutzerbezogene Routen
    get 'users/locked', to: 'users#locked', as: 'users_locked'

    #main_page
    get "positions", to: "positions#index"

    get "impressum", to: "static_pages#imprint"

    #analytics_page
    get "analytics", to: "analytics#index"
    
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
      
      # Application routes for different position types
      resources :volunteer_applications, only: [:new, :create]
      resources :freetime_registrations, only: [:new, :create]
      resources :assistant_applications, only: [:new, :create]
    end

    resources :organizations do
      member do
        patch 'release'
        patch 'lock'
      end
    end

    resources :universities do
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

    # Devise-Routen
    devise_for :users, controllers: {
      registrations: "users/registrations",
      confirmations: "users/confirmations",
      sessions: 'users/sessions'
    }

    # Eigene Devise-Routen im Mapping-Kontext
    devise_scope :user do
      # komplette Auswahlseite deaktivieren: leite /users/sign_up nach Organisation
      get 'users/sign_up', to: redirect('/%{locale}/users/sign_up/organization')

      # getrennte Registrierungen
      get 'users/sign_up/organization', to: 'users/registrations#new_organization', as: :new_organization_registration
      get 'users/sign_up/student', to: 'users/registrations#new_student', as: :new_student_registration
    end

    # Students are now users with role 3, so we use the main user routes
    # The students registration will be handled through the main user registration

    resources :show_positions, only: [:index, :show]
    
    # Temporary debug route
    get 'debug/schema', to: 'debug#schema'
  end
end