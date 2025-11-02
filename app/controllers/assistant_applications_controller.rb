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
      :first_name, :last_name, :gender, :phone_number, :email,
      :field_of_study, :semester, :gpa, :languages,
      :technical_skills, :previous_experience, :motivation,
      :cv, :cover_letter, :transcript, :certificates
    )
  end
end