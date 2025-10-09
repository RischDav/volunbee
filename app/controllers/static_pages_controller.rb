class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_status
  
  def imprint
  end

  def privacy
  end
end
