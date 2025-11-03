class AdminMailer < ApplicationMailer
  default from: "notifications@letsgovolunteer.com"

  def new_registration_email
    admin_email = ENV["ADMIN_EMAIL"]
    mail(to: admin_email, subject: "Neue Registrierung auf Volunteer-Heilbronn.de")
  end

  def new_position_email
    admin_email = ENV["ADMIN_EMAIL"]
    mail(to: admin_email, subject: "Neue Position auf Volunteer-Heilbronn.de")
  end

  def new_organization_and_position(organization, position)
    @organization = organization
    @position = position
    admin_email = ENV["ADMIN_EMAIL"]
    mail(to: admin_email, subject: "Neue Organisation und Position eingereicht")
  end

  def organization_change_email
    admin_email = ENV["ADMIN_EMAIL"]
    mail(to: admin_email, subject: "Änderung bei einer Organisation auf Volunteer-Heilbronn.de")
  end

  def position_change_email
    admin_email = ENV["ADMIN_EMAIL"]
    mail(to: admin_email, subject: "Änderungen bei einer Position auf Volunteer-Heilbronn.de")
  end
end