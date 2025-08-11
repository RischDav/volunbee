class Users::RegistrationsController < Devise::RegistrationsController
  # New separate pages for registration
  def new_organization
    build_resource({})
    @organization_name = resource.organization_name
    render 'devise/registrations/new_organization'
  end

  def new_student
    build_resource({})
    render 'devise/registrations/new_student'
  end

  def create
    build_resource(sign_up_params)
    
    # Prüfe die Rolle und handle entsprechend
    user_role = params[:user][:role]
    
    #Neu mit Fehlermeldung laden, wenn Passwort nicht stark genug
    unless password_strong_enough?(params[:user][:password])
      # Setze die Fehlermeldung für das Passwort
      resource.errors.add(:password, get_password_requirements_message)
      
      # Bereite die Ressource für die Anzeige vor
      clean_up_passwords(resource)
      set_minimum_password_length
      
      # Stelle die organization_name zurück in das Resource-Objekt (nur für Organisation)
      @organization_name = params[:user][:organization_name] if user_role == 'organization'
      
      # Rendere das Formular erneut, anstatt umzuleiten
      if user_role == 'organization'
        render 'devise/registrations/new_organization', status: :unprocessable_entity
      else
        render 'devise/registrations/new_student', status: :unprocessable_entity
      end
      return
    end

    #Wenn passwort stark genug ist, dann Folgender Weg:
    
    if user_role == 'organization'
      # Erstelle zuerst die Organisation
      organization = Organization.new(
        name: params[:user][:organization_name],
        organization_code: params[:user][:organization_name].downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '_')
      )

      ApplicationRecord.transaction do
        if organization.save && resource.save
          # Erstelle UserAffiliation für Organisation
          UserAffiliation.create!(
            user: resource,
            organization: organization,
            role: :user
          )

          yield resource if block_given?

          # Setze Flash-Nachrichten je nach Aktivierungsstatus
          if is_flashing_format?
            flash_key = resource.active_for_authentication? ? :signed_up : :"signed_up_but_#{resource.inactive_message}"
            set_flash_message! :notice, flash_key
          end

          # Wenn der Benutzer sofort aktiviert werden kann, melde ihn an
          sign_up(resource_name, resource) if resource.active_for_authentication?
          
          # Sende E-Mails nur für Organisationen
          AdminMailer.new_registration_email.deliver_later
          
          # WICHTIG: Setze temporären Token in der Session
          session[:temp_email_access] = resource.email
          
          # Leite direkt zur locked-Seite weiter, mit Email-Parameter
          redirect_to users_locked_path(email: resource.email)
          return
        else
          # Bei Fehlern: Rollback und Fehler anzeigen
          raise ActiveRecord::Rollback
        end
      end
      
      # Wenn wir hier ankommen, gab es Fehler
      organization.errors.full_messages.each { |msg| resource.errors.add(:base, msg) }
      clean_up_passwords resource
      set_minimum_password_length
      @organization_name = params[:user][:organization_name]
      render 'devise/registrations/new_organization', status: :unprocessable_entity
      return
      
    else
      # Student-Registrierung
      university = resource.determine_university_from_email
      
      unless university
        resource.errors.add(:email, "Diese E-Mail-Domain wird nicht unterstützt. Bitte verwende eine Hochschul-E-Mail-Adresse (z.B. @tum.de, @hs-heilbronn.de)")
        clean_up_passwords resource
        set_minimum_password_length
        render 'devise/registrations/new_student', status: :unprocessable_entity
        return
      end

      ApplicationRecord.transaction do
        if resource.save
          # Erstelle UserAffiliation für Student
          UserAffiliation.create!(
            user: resource,
            university: university,
            role: :user
          )

          yield resource if block_given?

          # Setze Flash-Nachrichten je nach Aktivierungsstatus
          if is_flashing_format?
            flash_key = resource.active_for_authentication? ? :signed_up : :"signed_up_but_#{resource.inactive_message}"
            set_flash_message! :notice, flash_key
          end

          # Wenn der Benutzer sofort aktiviert werden kann, melde ihn an
          sign_up(resource_name, resource) if resource.active_for_authentication?
          
          # WICHTIG: Setze temporären Token in der Session
          session[:temp_email_access] = resource.email
          
          # Leite direkt zur locked-Seite weiter, mit Email-Parameter
          redirect_to users_locked_path(email: resource.email)
          return
        else
          # Bei Fehlern: Rollback
          raise ActiveRecord::Rollback
        end
      end
      
      # Wenn wir hier ankommen, gab es Fehler
      clean_up_passwords resource
      set_minimum_password_length
      render 'devise/registrations/new_student', status: :unprocessable_entity
      return
    end
  end

  def authorize_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Access Denied"
    end
  end

  private

  # Definiert die erlaubten Parameter beim Registrieren eines Benutzers
  def sign_up_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :organization_name,
      :role
    )
  end

  def password_strong_enough?(password)
    return false if password.nil? || password.length < 8
    
    # Prüfe auf Großbuchstaben
    return false unless password =~ /[A-Z]/
    
    # Prüfe auf Kleinbuchstaben
    return false unless password =~ /[a-z]/

    # Prüfe auf Zahlen
    return false unless password =~ /[0-9]/
    
    # Prüfe auf Sonderzeichen
    return false unless password =~ /[^A-Za-z0-9]/
    
    true
  end
  
  def get_password_requirements_message
    "Das Passwort muss mindestens 8 Zeichen lang sein und mindestens einen Großbuchstaben, " +
    "einen Kleinbuchstaben, eine Zahl und ein Sonderzeichen enthalten."
  end

  protected

  # Diese Methode wird aufgerufen, wenn ein User sich registriert hat,
  # aber nicht aktiv ist (z.B. wegen fehlender Email-Bestätigung)
  def after_inactive_sign_up_path_for(resource)
    # Setze auch hier den temporären Token (falls die andere Methode nicht greift)
    session[:temp_email_access] = resource.email if resource
    users_locked_path(email: resource.email)
  end

  # Diese Methode wird aufgerufen, wenn ein User sich registriert hat
  # und sofort aktiv ist
  def after_sign_up_path_for(resource)
    users_locked_path
  end
end
