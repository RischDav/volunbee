class ApplicationController < ActionController::Base
  before_action :authenticate_user!  
  before_action :check_user_status, unless: -> { devise_controller? }
  before_action :set_locale
  
  private

  # Setzt die Locale für die Anwendung
  def set_locale
    I18n.locale = params[:locale] || extract_locale || I18n.default_locale
  end
  
  # Extrahiert die Locale aus den Parametern oder dem HTTP-Header
  def extract_locale
    parsed_locale = params[:locale] || request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    parsed_locale if I18n.available_locales.map(&:to_s).include?(parsed_locale)
  end

  # Fügt die aktuelle Locale zu allen generierten URLs hinzu
  def default_url_options
    { locale: I18n.locale }
  end

  # Überprüft den Status des Benutzers. Wenn er nicht vollen Zugriff hat, wird er zur gesperrten Seite weitergeleitet.
  def check_user_status
    if user_signed_in? && 
       !current_user.full_access? && # Verwende die neue Methode
       request.path != user_locked_path
      redirect_to user_locked_path
    end
  end
end