class PositionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position, only: [ :edit, :update, :destroy ]

  def index
    if user_signed_in?
      if current_user.admin?
        @positions = Position.all
      else
        @positions = Position.where(organization_id: current_user.organization_id)
      end
      @positions_count = @positions.size
    else
      @positions = nil
    end
  end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(position_params)
    @position.organization_id = current_user.organization_id

    if @position.save
      @position.pictures.each do |picture|
        ProcessPictureJob.perform_later(picture)
      end
      redirect_to positions_path, notice: "Position was successfully created."
    else
      render :new
    end
  end

  def edit
    # @position wird durch before_action :set_position gesetzt
  end

  def update
    if @position.update(position_params)
      @position.pictures.each do |picture|
        ProcessPictureJob.perform_later(picture)
      end
      redirect_to positions_path, notice: "Position was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @position.destroy
    redirect_to positions_path, notice: "Position was successfully deleted."
  end

  private

  def set_position
    @position = Position.find(params[:id])
  end

  def position_params
    params.require(:position).permit(:title, :description, :is_active, pictures: [])
  end
end
