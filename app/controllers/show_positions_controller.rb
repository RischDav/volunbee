class ShowPositionsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index]
    layout 'volunteer'
    def index
    end
  end
    