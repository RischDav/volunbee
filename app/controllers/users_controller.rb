# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # Kein authenticate_user! für diese Action
  skip_before_action :authenticate_user!, only: [:locked]
  skip_before_action :check_user_status, only: [:locked]
  
  def locked
    # E-Mail aus Parameter holen
    @email = params[:email]
    
    if user_signed_in?
      @email_confirmed = current_user.confirmed?
      @user_released = current_user.released?
    elsif @email.present?
      # Informationen basierend auf E-Mail-Parameter anzeigen
      @user = User.find_by(email: @email)
      @email_confirmed = @user&.confirmed? || false
      @user_released = @user&.released? || false
    else
      # Falls weder eingeloggt noch E-Mail-Parameter
      @email_confirmed = false
      @user_released = false
    end
  end
end