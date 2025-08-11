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

    #students
    get "students", to: "students#index"
    get 'students/locked', to: 'students#locked', as: 'students_locked'
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
    resources :students, only: [:index]
  end
end