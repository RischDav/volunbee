class UserMailer < ApplicationMailer
  default from: "notifications@letsgovolunteer.com"

  def welcome_email
    mail(to: "david.rischow@mail.de", subject: "Wilkommen bei volunteer-heilbronn.de")
  end

  def unlocked_welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Dein Account wurde freigeschaltet!")
  end

end
