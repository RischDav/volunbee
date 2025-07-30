class Students::SessionsController < Devise::SessionsController
  # You can add custom logic here if needed

  def create
    student = Student.find_by(email: sign_in_params[:email])

    # Check if student entered correct password
    if student && student.valid_password?(sign_in_params[:password])
      # If student has not confirmed their email
      if !student.confirmed?
        session[:temp_email_access] = student.email
        return redirect_to students_locked_path(email: student.email) # Make sure this route exists or adjust as needed
      else
        sign_in(student)
      end
    end
    # If none of the above, proceed with normal Devise login
    super
  end
end 