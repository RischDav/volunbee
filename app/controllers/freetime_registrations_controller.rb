class FreetimeRegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_position

  def new
    @freetime_registration = FreetimeRegistration.new
  end

  def create
    @freetime_registration = FreetimeRegistration.new(freetime_registration_params)
    @freetime_registration.position = @position
    @freetime_registration.user = current_user

    if @freetime_registration.save
      PositionApplicationMailer.submit_confirmation_to_user(@freetime_registration).deliver_later
      PositionApplicationMailer.new_application_notification_to_organization(@freetime_registration).deliver_later
      redirect_to @position, notice: 'Your registration for this freetime activity has been submitted successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_position
    @position = Position.find(params[:position_id])
  end

  def freetime_registration_params
    params.require(:freetime_registration).permit(
      :first_name, :last_name, :email, :gender, :age, :phone_number,
      :dietary_restrictions, :emergency_contact_name, :emergency_contact_phone,
      :additional_info
    )
  end
end