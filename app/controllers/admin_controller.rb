class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def index
    @users = User.all
  end

  def release_user
    user = User.find(params[:id])
    user.update(released: true)
    redirect_to admin_index_path, notice: 'Benutzer wurde freigegeben.'
  end

  def lock_user
    user = User.find(params[:id])
    user.update(released: false)
    redirect_to admin_index_path, notice: 'Benutzer wurde gesperrt.'
  end

  private

  def check_admin
    redirect_to root_path unless current_user.admin?
  end
end