class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = User.find_by(email: sign_in_params[:email])
    user = self.resource

    if user && user.valid_password?(sign_in_params[:password])
      if !user.confirmed?
        session[:temp_email_access] = user.email
        return redirect_to users_locked_path(email: user.email)
      elsif user.organization && !user.organization.complete_profile?
        sign_in(user)
        return redirect_to edit_organization_path(user.organization)
      end
    end
    super
  end
end