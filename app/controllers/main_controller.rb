class MainController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  layout 'volunteer'
  
  def index
    # Your code here
  end
end
  