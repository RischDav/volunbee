class ApplicationController < ActionController::Base
  before_action :authenticate_user!  
  before_action :check_user_status, unless: -> { devise_controller? }

  private

  def check_user_status
    if user_signed_in? && 
       (!current_user.confirmed? || !current_user.released?) && 
       !current_user.admin? && 
       request.path != user_locked_path
      redirect_to user_locked_path
    end
  end
end