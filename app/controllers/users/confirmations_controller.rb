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

  # Wohin nach Bestätigung der E-Mail
  def after_confirmation_path_for(resource_name, resource)
    #if resource.released?
      root_path # Oder dashboard_path
    #else
    #  users_locked_path
    #end
  end

  # Wohin nach erneutem Senden der Bestätigungs-E-Mail
  def after_resending_confirmation_instructions_path_for(resource_name)
    user_locked_path(email: resource.email)
  end
end