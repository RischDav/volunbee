class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    @users = User.all
    @users = User.includes(:organization).all
    @users_count = @users.size
  end

  def authorize_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Access Denied"
    end
  end
end
