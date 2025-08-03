class MainController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    @custom_navbar = true
    @positions = Position.where(released: true, online: true).select { |position| position.main_picture.attached? }.take(3)
  end
end