class MainController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    # Umleitung für eingeloggte User
    if user_signed_in?
      if current_user.admin?
        redirect_to positions_path and return  
      elsif current_user.organization?
        redirect_to organizations_path and return
      elsif current_user.university?
        redirect_to positions_path and return  # oder eine andere Seite für Unis
      end
    end
    
    @custom_navbar = true
    @positions = Position.where(released: true, online: true).select { |position| position.main_picture.attached? }.take(3)
  end
end