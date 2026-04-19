class EventRegistrationsController < ApplicationController
  before_action :set_event
  before_action :authenticate_user!
  before_action :initialize_registration_object, only: [:new]

  def new
    # Rendert event_registrations/new.html.erb
  end

  def create
    @registration = Message.new(registration_params)
    @registration.event = @event
    @registration.user = current_user
    @registration.email = current_user.email
    @registration.type = 'event_registration'

    if @registration.save
      # Optional: Mailer für Bestätigung und Benachrichtigung des Veranstalters
      begin
        EventRegistrationMailer.confirmation_to_user(@registration).deliver_later
        EventRegistrationMailer.notification_to_organization(@registration).deliver_later
      rescue => e
        Rails.logger.error "Mailer Error: #{e.message}"
      end

  redirect_to event_event_registration_path(@event, @registration),
                  notice: "Erfolgreich für das Event angemeldet!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @registration = Message.event_registrations.find(params[:id])
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def initialize_registration_object
    @registration = Message.new
  end

  def registration_params
    params.require(:message).permit(:first_name, :last_name, :age)
  end
end