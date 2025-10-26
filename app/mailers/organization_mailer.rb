# app/mailers/organization_mailer.rb
class OrganizationMailer < ApplicationMailer
  def position_submitted(organization, position)
    @organization = organization
    @position = position
    mail(
      to: @organization.email,
      subject: "Ihre Freizeitaktivität wurde eingereicht"
    )
  end
end