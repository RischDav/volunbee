class Students::RegistrationsController < Devise::RegistrationsController
  private
  def sign_up_params
    params.require(:student).permit(:name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:student).permit(:name, :last_name, :email, :password, :password_confirmation, :current_password)
  end

  def build_resource(hash = {})
    super(hash)
    self.resource.role = :student
    self.resource.university = determine_university_from_email(resource.email) if resource.email.present?
  end

  def determine_university_from_email(email)
    return nil unless email.present?
    
    if email.end_with?('@tum.de') || email.end_with?('@mytum.de')
      University.find_by(name: 'Technische Universität München')
    elsif email.end_with?('@hs-heilbronn.de')
      University.find_by(name: 'Hochschule Heilbronn')
    end
  end
end 