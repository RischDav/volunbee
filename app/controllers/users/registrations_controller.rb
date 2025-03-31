class Users::RegistrationsController < Devise::RegistrationsController
  def create

    build_resource(sign_up_params)

    unless password_strong_enough?(params[:user][:password])
      # Setze die Fehlermeldung für das Passwort
      resource.errors.add(:password, get_password_requirements_message)
      
      # Bereite die Ressource für die Anzeige vor
      clean_up_passwords(resource)
      set_minimum_password_length
      
      # Stelle die organization_name zurück in das Resource-Objekt
      @organization_name = params[:user][:organization_name]
      
      # Rendere das Formular erneut, anstatt umzuleiten
      respond_with(resource)
      return
    end

    # Erstelle zuerst die Organisation
    organization = Organization.new(
      name: params[:user][:organization_name],
      organization_code: params[:user][:organization_name].downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '_')
    )

    if organization.save
      # Wenn die Organisation erfolgreich gespeichert wurde, weise sie dem Benutzer zu
      resource.organization_id = organization.id
      resource.save

      yield resource if block_given?

      if resource.persisted?
        # Setze Flash-Nachrichten je nach Aktivierungsstatus
        if is_flashing_format?
          flash_key = resource.active_for_authentication? ? :signed_up : :"signed_up_but_#{resource.inactive_message}"
          set_flash_message! :notice, flash_key
        end

        # Wenn der Benutzer sofort aktiviert werden kann, melde ihn an
        sign_up(resource_name, resource) if resource.active_for_authentication?
        
        # Sende E-Mails
        AdminMailer.new_registration_email.deliver_later
        
        # WICHTIG: Setze temporären Token in der Session
        session[:temp_email_access] = resource.email
        
        # Leite direkt zur locked-Seite weiter, mit Email-Parameter
        redirect_to users_locked_path(email: resource.email)
        return # Wichtig: Beendet die Methode hier
      else
        # Wenn der Benutzer nicht erstellt werden konnte
        organization.destroy! # Lösche auch die Organisation
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      # Wenn die Organisation nicht erstellt werden konnte
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource, location: new_registration_path(resource_name)
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
      :organization_name
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
    user_locked_path(email: resource.email)
  end

  # Diese Methode wird aufgerufen, wenn ein User sich registriert hat
  # und sofort aktiv ist
  def after_sign_up_path_for(resource)
    user_locked_path
  end
end