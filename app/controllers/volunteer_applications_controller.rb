class VolunteerApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position

  def new
    @volunteer_application = VolunteerApplication.new
  end

  def create
    @volunteer_application = VolunteerApplication.new(volunteer_application_params)
    @volunteer_application.position = @position
    @volunteer_application.user = current_user

    if @volunteer_application.save
      PositionApplicationMailer.submit_confirmation_to_user(@volunteer_application).deliver_later
      PositionApplicationMailer.new_application_notification_to_organization(@volunteer_application).deliver_later
      redirect_to @position, notice: 'Your volunteer application has been submitted successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_position
    @position = Position.find(params[:position_id])
  end

  def volunteer_application_params
    params.require(:volunteer_application).permit(
      :first_name, :last_name, :email, :gender, :age, :phone_number,
      :has_volunteer_experience, :volunteer_experience_description,
      :about_yourself
    )
  end
end