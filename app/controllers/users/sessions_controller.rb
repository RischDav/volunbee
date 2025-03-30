class Users::SessionsController < Devise::SessionsController
  def create
    puts "Hi! Ich bin in create!!!"
    user = User.find_by(email: sign_in_params[:email])
    
    if user && user.valid_password?(sign_in_params[:password]) && (!user.confirmed? || !user.released?)
      # Session-Token setzen und weiterleiten
      session[:temp_email_access] = user.email
      redirect_to users_locked_path(email: user.email)
    else
      # Normaler Login-Prozess
      super
    end
  end
end