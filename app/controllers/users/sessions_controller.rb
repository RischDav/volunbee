class Users::SessionsController < Devise::SessionsController
  def create
    user = User.find_by(email: sign_in_params[:email])

    #prüft, ob user beim login richtiges passwort eingegeben hat
    if user && user.valid_password?(sign_in_params[:password])
      #if wenn user noch nicht seine email bestätigt hat
      if !user.confirmed?
        session[:temp_email_access] = user.email
        return redirect_to users_locked_path(email: user.email)
      #Wenn user Mail bestätigt hat, aber Organisationsprofil noch unvollständig ist  
      else 
        sign_in(user)
      end
    end
    #Wenn kein if zutrifft, wird der User normal eingeloggt
    super
  end
end