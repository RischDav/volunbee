class AssistantApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position

  def new
    @assistant_application = AssistantApplication.new
  end

  def create
    @assistant_application = AssistantApplication.new(assistant_application_params)
    @assistant_application.position = @position
    @assistant_application.user = current_user

    if @assistant_application.save
      PositionApplicationMailer.submit_confirmation_to_user(@assistant_application).deliver_later
      PositionApplicationMailer.new_application_notification_to_organization(@assistant_application).deliver_later
      redirect_to @position, notice: 'Your assistant application has been submitted successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_position
    @position = Position.find(params[:position_id])
  end

  def assistant_application_params
  params.require(:assistant_application).permit(
    :first_name, :last_name, :email, :phone_number, :birth_date, :gender, :age,
    :has_experience, :experience_description, :motivation, :about_yourself, :cv_file
  )
  end
end