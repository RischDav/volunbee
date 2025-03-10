class ApplicationController < ActionController::Base
  before_action :check_user_released, unless: -> { devise_controller? }

  private

  def check_user_released
    if user_signed_in? && !current_user.released? && !current_user.admin? && request.path != user_locked_path
      redirect_to user_locked_path
    end
  end
end