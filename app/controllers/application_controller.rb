class ApplicationController < ActionController::Base
  before_action :authenticate_user!  
  before_action :check_user_status, unless: -> { devise_controller? }
  before_action :set_locale
  
  private
  
  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end
  
  def extract_locale
    parsed_locale = params[:locale] || request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    parsed_locale if I18n.available_locales.map(&:to_s).include?(parsed_locale)
  end
end

  def check_user_status
    if user_signed_in? && 
       !current_user.full_access? && # Verwende die neue Methode
       request.path != user_locked_path
      redirect_to user_locked_path
    end
  end