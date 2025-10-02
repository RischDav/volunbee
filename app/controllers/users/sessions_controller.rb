class Users::SessionsController < Devise::SessionsController
  # POST /users/sign_in
  def create
    super do |user|
      # === UserEvent Tracking ===
      if user.organization?
        UserEvent.create!(
          user_type: :organization_staff,
          action_type: :logged_in,
          organization: user.organization
        )
      elsif user.university? && user.student?
        UserEvent.create!(
          user_type: :student,
          action_type: :logged_in,
          university: user.university
        )
      elsif user.university? && user.university_staff?
        UserEvent.create!(
          user_type: :university_staff,
          action_type: :logged_in,
          university: user.university
        )
      end

      # === E-Mail nicht bestätigt ===
      if !user.confirmed?
        session[:temp_email_access] = user.email
        return redirect_to users_locked_path(email: user.email)
      end
    end
  end

  protected

  # Nach Login weiterleiten
  def after_sign_in_path_for(resource)
    root_path
  end
end
