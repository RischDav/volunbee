class Students::ConfirmationsController < Devise::ConfirmationsController
  # You can add custom logic here if needed

  # GET /resource/confirmation/new
  def new
    super
  end

  # POST /resource/confirmation
  def create
    super
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super
  end

  protected

  # After confirmation, sign in the student and redirect to root
  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource) if resource.is_a?(Student)
    root_path
  end

  # After resending confirmation instructions, redirect to locked page
  def after_resending_confirmation_instructions_path_for(resource_name)
    students_locked_path(email: resource.email) # Make sure this route exists or adjust as needed
  end
end 