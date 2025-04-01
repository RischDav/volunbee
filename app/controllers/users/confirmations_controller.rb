# app/controllers/users/confirmations_controller.rb
class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  def new
    super
  end

  # POST /resource/confirmation
  def create
    super
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super
  end

  protected

  # Nach der Bestätigung der Mail wird der User automatisch zur Startseite weitergeleitet
  def after_confirmation_path_for(resource_name, resource)
    #Nachfolgendes Prüfen auf Bugs!!!!
    sign_in(resource_name, resource) if resource.is_a?(User)
    user_locked_path(email: resource.email)
  end

  # Nach dem erneuten senden der Mail wird der User zur Seite weitergeleitet, auf der er den Status seiner Bestätigung sehen kann
  def after_resending_confirmation_instructions_path_for(resource_name)
    user_locked_path(email: resource.email)
  end
end