# app/controllers/users_controller.rb
class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:locked], if: -> { params[:email].present? }
  skip_before_action :check_user_status, only: [:locked]
  
  def locked
    if user_signed_in?
      # Angemeldeter Benutzer, zeige seinen Status
      @email = current_user.email
      @email_confirmed = current_user.confirmed?
      @user_released = current_user.released?
    elsif params[:email].present?
      # E-Mail-Parameter: Nur für spezifische Fälle erlauben (z.B. nach Registrierung)
      @email = params[:email]
      @user = User.find_by(email: @email)
      if @user && session[:temp_email_access] == @email
        @email_confirmed = @user.confirmed?
        @user_released = @user.released?
      else
        # Nicht authentifizierter Zugriff ohne Session-Token
        redirect_to new_user_session_path, alert: "Bitte melden Sie sich an"
        return
      end
    else
      # Keine E-Mail und nicht eingeloggt
      redirect_to new_user_session_path
      return
    end
  end
end