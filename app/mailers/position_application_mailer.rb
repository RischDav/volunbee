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
  @organization = @position.organization
  @contact_name = @organization.name

  mail(to: @organization.email, subject: "Neue Bewerbung: #{@position.title}")
  end
end