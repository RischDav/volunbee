class MainController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  layout 'volunteer'
  
  def index
    @positions = Position.all.limit(3)
    @organisations = Organisation.all
  end
end