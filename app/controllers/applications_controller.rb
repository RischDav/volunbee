class ApplicationsController < ApplicationController
  before_action :set_position
  before_action :authenticate_user!, except: [:show]
  before_action :initialize_application_object, only: [:new, :create]

  def new
    # @application_object is set by initialize_application_object
  end

  def create
    @application_object = Message.new(application_params)
    @application_object.position = @position
    @application_object.user = current_user if user_signed_in?
    @application_object.type = application_type_for_position

    if @application_object.save
      redirect_to position_application_path(@position, @application_object), 
                  notice: t("applications.create.success.#{@position.type}", 
                           default: 'Your application has been submitted successfully!')
    else
      # Re-initialize for form rendering
      initialize_application_object
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @application_object = Message.applications.find(params[:id])
    @application_type = @application_object.type
  end

  private

  def set_position
    @position = Position.find(params[:position_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to positions_path, alert: t('positions.not_found', default: 'Position not found.')
  end

  def initialize_application_object
    @application_object = Message.new
    case @position.type
    when 'volunteering'
      @application_type = 'volunteer'
    when 'freetime'
      @application_type = 'freetime'
    when 'university_position'
      @application_type = 'assistant'
    else
      redirect_to position_path(@position), alert: 'Invalid position type'
    end
  end

  def application_type_for_position
    case @position.type
    when 'volunteering'
      'volunteer_application'
    when 'freetime'
      'freetime_registration'
    when 'university_position'
      'assistant_application'
    end
  end

  def application_params
    case @position.type
    when 'volunteering'
      params.require(:message).permit(
        :first_name, :last_name, :email, :age, :gender,
        :has_experience, :experience_description, :has_volunteer_experience, 
        :volunteer_experience_description, :motivation, :about_yourself
      )
    when 'freetime'
      params.require(:message).permit(
        :first_name, :last_name, :email, :age, :gender
      )
      
    when 'university_position'
      params.require(:message).permit(
        :first_name, :last_name, :email, :age, :gender,
        :has_experience, :experience_description
      )
    end
  end
end