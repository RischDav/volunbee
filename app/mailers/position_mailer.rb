class PositionMailer < ApplicationMailer
  default from: "notifications@letsgovolunteer.com"

  def position_modified(user, position, changes)
    @user = user
    @position = position
    @changes = changes
    @position_url = position_url(@position, locale: :de)
    
    mail(
      to: @user.email,
      subject: "Position \"#{@position.title}\" wurde aktualisiert"
    )
  end

  def position_modified_creator(creator, position, changes)
    @creator = creator
    @position = position
    @changes = changes
    @position_url = position_url(@position, locale: :de)
    @applicant_count = @position.messages.applications.count
    
    mail(
      to: @creator.email,
      subject: "Bestätigung: Ihre Position \"#{@position.title}\" wurde erfolgreich aktualisiert"
    )
  end

  def application_submitted(application)
    @application = application
    @position = application.position
    @applicant_name = "#{application.first_name} #{application.last_name}"
    @position_url = position_url(@position, locale: :de)
    
    # Determine application type for subject
    application_type = case @application.type
    when 'volunteer_application'
      'Ehrenamt'
    when 'freetime_registration'
      'Freizeitaktivität'
    when 'assistant_application'
      'Studentische Hilfskraft'
    else
      'Position'
    end
    
    mail(
      to: @application.email,
      subject: "Bewerbungsbestätigung: #{application_type} - \"#{@position.title}\""
    )
  end
end