class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  #Zeige alle user
  def index
    @users = User.all
  end

  #setzt den Status des Benutzers auf "freigegeben" und sendet eine E-Mail
  def release_user
    @user = User.find(params[:id])
    @user.update(released: true)
    UserMailer.unlocked_welcome_email(@user).deliver_later
    redirect_to admin_index_path, notice: 'Benutzer wurde freigegeben.'
  end

  #setzt den Status des Benutzers auf "gesperrt"
  def lock_user
    user = User.find(params[:id])
    user.update(released: false)
    redirect_to admin_index_path, notice: 'Benutzer wurde gesperrt.'
  end

  private

  #Überprüft, ob der aktuelle Benutzer ein Administrator ist
  def check_admin
    redirect_to root_path unless current_user.admin?
  end
end