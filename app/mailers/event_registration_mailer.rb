class EventRegistrationMailer < ApplicationMailer
  def confirmation_to_user(registration)
    @registration = registration
    @event = registration.event
    mail(to: registration.email, subject: "Deine Anmeldung für #{@event.title}")
  end

  def notification_to_organization(registration)
    @registration = registration
    @event = registration.event
    organization_email = @event.organization&.email
    if organization_email.present?
      mail(to: organization_email, subject: "Neue Anmeldung für dein Event #{@event.title}")
    end
  end
end