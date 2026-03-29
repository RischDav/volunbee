class PositionApplicationMailer < ApplicationMailer
  def submit_confirmation_to_user(application)
    @application = application
    @user = application.user
    @position = application.position

    mail(
      to: @user.email,
      subject: "Confirmation of your application for '#{@position.title}'"
    )
  end

  def new_application_notification_to_organization(application)
    @application = application
    @position = application.position
    @contact_person = @position.contact_person

    mail(
      to: @contact_person.email,
      subject: "Neuer Interessent für '#{@position.title}'"
    )
  end
end