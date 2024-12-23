class PositionsController < ApplicationController
  before_action :authenticate_user!, only: [ :index ] # Sicherstellen, dass der User eingeloggt ist

  def index
    if user_signed_in? # Prüfen, ob ein User eingeloggt ist
      @positions = Position.where(organization_id: current_user.organization_id)
    else
      @positions = nil # Fallback, wenn kein User eingeloggt ist
    end
  end
end
