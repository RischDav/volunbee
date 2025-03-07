# Diese Klasse erbt von Devise::RegistrationsController und überschreibt die Methode `create`,
# die für die Registrierung eines neuen Benutzers verantwortlich ist.
class Users::RegistrationsController < Devise::RegistrationsController
  # Überschreibt die `create`-Methode, die aufgerufen wird, wenn ein neuer Benutzer sich registrieren möchte.
  def create
    # Erstellt ein neues User-Objekt (`resource`) mit den Registrierungsparametern.
    build_resource(sign_up_params)

    # Erstellt ein neues Organization-Objekt basierend auf dem in den Parametern übergebenen Namen.
    organization = Organization.new(
      name: params[:user][:organization_name] # Der Name der Organisation wird aus den Parametern geholt.
    )

    # Prüft, ob die Organisation erfolgreich gespeichert werden konnte.
    if organization.save
      # Wenn die Organisation erfolgreich gespeichert wurde, wird die Organisation dem Benutzer zugewiesen.
      resource.organization_id = organization.id
      resource.save # Speichert den Benutzer in der Datenbank.

      # Falls ein Block an die Methode übergeben wurde, wird dieser hier ausgeführt.
      yield resource if block_given?

      # Prüft, ob der Benutzer erfolgreich gespeichert wurde.
      if resource.persisted?
        # Wenn der Benutzer aktiv ist und sich authentifizieren kann, wird er eingeloggt.
        if resource.active_for_authentication?
          # Zeigt eine Erfolgsmeldung an.
          set_flash_message! :notice, :signed_up
          # Loggt den Benutzer ein.
          sign_up(resource_name, resource)
          # Leitet den Benutzer zur `after_sign_up_path_for`-Methode weiter.
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          # Wenn der Benutzer nicht aktiv ist, zeigt eine andere Nachricht an (z.B. bei Bestätigung erforderlich).
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          # Entfernt temporäre Daten, die während der Anmeldung gespeichert wurden.
          expire_data_after_sign_in!
          # Leitet den Benutzer zur `after_inactive_sign_up_path_for`-Methode weiter.
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        # Wenn der Benutzer nicht erfolgreich gespeichert wurde:
        organization.destroy!
        clean_up_passwords resource # Bereinigt die Passwortdaten (z.B. entfernt Passworthashes).
        set_minimum_password_length # Setzt die Mindestpasswortlänge.
        respond_with resource # Gibt den Benutzer zurück (z.B. um Fehler anzuzeigen).
      end
    else
      UserMailer.with(user: sign_up_params.email).welcome_email.deliver_later
      # Wenn die Organisation nicht gespeichert werden konnte:
      clean_up_passwords resource # Bereinigt die Passwortdaten.
      set_minimum_password_length # Setzt die Mindestpasswortlänge.
      # Leitet den Benutzer zur Registrierungsseite zurück und zeigt Fehler an.
      respond_with resource, location: new_registration_path(resource_name)
    end
  end

  def authorize_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Access Denied"
    end
  end

  private

  # Definiert die erlaubten Parameter, die beim Registrieren eines Benutzers übermittelt werden dürfen.
  def sign_up_params
    params.require(:user).permit(
      :email,                # E-Mail-Adresse des Benutzers
      :password,             # Passwort des Benutzers
      :password_confirmation, # Bestätigung des Passworts
      :organization_name     # Name der Organisation, die der Benutzer erstellt
    )
  end
end
