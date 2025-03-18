class Users::RegistrationsController < Devise::RegistrationsController
  # Überschreibt die `create`-Methode, die aufgerufen wird, wenn ein neuer Benutzer sich registrieren möchte.
  def create
    # Erstellt ein neues User-Objekt mit den Registrierungsparametern.
    build_resource(sign_up_params)

    # Erstellt ein neues Organization-Objekt basierend auf dem übergebenen Namen.
    organization = Organization.new(
      name: params[:user][:organization_name]
    )

    # Prüft, ob die Organisation erfolgreich gespeichert werden konnte.
    if organization.save
      # Wenn die Organisation erfolgreich gespeichert wurde, wird sie dem Benutzer zugewiesen.
      resource.organization_id = organization.id
      resource.save # Speichert den Benutzer in der Datenbank.

      # Falls ein Block an die Methode übergeben wurde, wird dieser hier ausgeführt.
      yield resource if block_given?

      # Prüft, ob der Benutzer erfolgreich gespeichert wurde.
      if resource.persisted?
        # Setze Erfolgsmeldung je nach Status (bestätigt/nicht bestätigt)
        if is_flashing_format?
          flash_key = resource.active_for_authentication? ? :signed_up : :"signed_up_but_#{resource.inactive_message}"
          set_flash_message! :notice, flash_key
        end

        # Wenn der Benutzer aktiv ist, melde ihn an
        sign_up(resource_name, resource) if resource.active_for_authentication?
        
        # Sende E-Mails
        #UserMailer.welcome_email(resource).deliver_later
        AdminMailer.new_registration_email.deliver_later
        
        # Leite direkt zur locked-Seite weiter, unabhängig vom Bestätigungsstatus
        redirect_to user_locked_path(email: resource.email)
        return # Wichtig: Beendet die Methode hier
      else
        # Wenn der Benutzer nicht erfolgreich gespeichert wurde:
        organization.destroy!
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      # Wenn die Organisation nicht gespeichert werden konnte:
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
end