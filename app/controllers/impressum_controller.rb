class ImpressumController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    @custom_navbar = true
  end
end