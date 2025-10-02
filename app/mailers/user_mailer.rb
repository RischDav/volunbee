class UserMailer < ApplicationMailer
  default from: "notifications@letsgovolunteer.com"

  #Wird Stand jetzt nicht verwendet, da Bestätigungsmail von Devises alle Informationen enthält
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Wilkommen bei Volunbee!")
  end

  def unlocked_welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Dein Account wurde freigeschaltet!")
  end

end
