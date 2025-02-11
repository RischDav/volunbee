class PositionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position, only: [:edit, :update, :destroy]

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
    puts params[:position][:frequently_asked_questions_attributes]
    @position.organization_id = current_user.organization_id

    if @position.save
      [@position.mainPicture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
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
      [@position.mainPicture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
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
    params.require(:position).permit(:title, :description, :benefits, :mainPicture, :picture1, :picture2, :picture3, frequently_asked_questions_attributes: [:id, :question, :answer, :_destroy])
  end
end