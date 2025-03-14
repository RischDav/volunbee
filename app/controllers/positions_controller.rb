class PositionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position, only: [:show, :edit, :update, :destroy, :release, :lock, :delete_picture]

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
      [@position.mainPicture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
      end
      redirect_to positions_path, notice: "Position was successfully created."
      AdminMailer.new_position_email.deliver_later
    else
      render :new
    end
  end

  def edit
    AdminMailer.position_change_email.deliver_later
  end

  def json_output
    positions = Position.where(released: true, online: true)
    render json: positions.as_json(methods: :picture_urls)
  end

  def show
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

  def release
    position = Position.find(params[:id])
    position.update(released: true)
    redirect_to positions_path, notice: 'Position wurde freigegeben.'
  end

  def offline
    position = Position.find(params[:id])
    position.update(online: false)
    redirect_to positions_path, notice: 'Position wurde offline gestellt.'
  end

  def online
    position = Position.find(params[:id])
    position.update(online: true)
    redirect_to positions_path, notice: 'Position wurde online gestellt.'
  end

  def lock
    position = Position.find(params[:id])
    position.update(released: false)
    redirect_to positions_path, notice: 'Position wurde gesperrt.'
  end

  def delete_picture
    picture_type = params[:picture_type]
    if @position.respond_to?(picture_type) && @position.send(picture_type).attached?
      @position.send(picture_type).purge
      redirect_to edit_position_path(@position), notice: "#{picture_type.humanize} wurde gelöscht."
    else
      redirect_to edit_position_path(@position), alert: "Bild konnte nicht gelöscht werden."
    end
  end

  private

  def set_position
    @position = Position.find(params[:id])
  end

  def position_params
    params.require(:position).permit(:title, :description, :benefits, :mainPicture, :picture1, :picture2, :picture3, :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility, :released, :online, frequently_asked_questions_attributes: [:id, :question, :answer, :_destroy])
  end
end