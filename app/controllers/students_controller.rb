class StudentsController < ApplicationController
  skip_before_action :authenticate_user!
  def index
  end

  def locked
    if student_signed_in?
      @student = current_student
      @confirmed = @student.confirmed?
      @student_email = @student.email
    elsif params[:email].present?
      @student = Student.find_by(email: params[:email])
      @student_email = params[:email]
      @confirmed = @student&.confirmed?
    end
  end
end 