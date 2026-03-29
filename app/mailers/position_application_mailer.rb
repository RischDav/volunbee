class PositionApplicationMailer < ApplicationMailer
  def submit_confirmation_to_user(application)
    @application = application
    @position = application.position

    mail(
      to: @application.email,
      subject: "Confirmation of your application for '#{@position.title}'"
    )
  end

  def new_application_notification_to_organization(application)
    @application = application
    @position = application.position
    @organization = @position.organization
    
    # KORREKTUR: contact_person liegt laut Schema in der Tabelle organizations!
    @contact_name = @organization.contact_person.presence || @organization.name

    mail(
      to: @organization.email, 
      subject: "Neue Bewerbung: #{@position.title}"
    )
  end
end