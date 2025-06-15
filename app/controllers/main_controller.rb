class MainController < ApplicationController
  def index
    @positions = Position.where(released: true, online: true).select { |position| position.main_picture.attached? }.take(3)
  end
end