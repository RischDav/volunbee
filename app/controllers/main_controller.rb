class MainController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  layout 'volunteer'
  
  def index
    @positions = Position.all.select { |position| position.main_picture.attached? }.take(3)
    
  end
end