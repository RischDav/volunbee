class ApplicationsController < ApplicationController
  before_action :set_position
  before_action :authenticate_user!, except: [:show]
  before_action :initialize_application_object, only: [:new]

  def new
    # Rendert positions/applications/new.html.erb
  end

  def create
  @application_object = Message.new(application_params)
  @application_object.position = @position
  
  if user_signed_in?
    @application_object.user = current_user
    # Wir überschreiben die E-Mail mit der echten User-Mail, egal was im Formular stand
    @application_object.email = current_user.email 
  end
  
  @application_object.type = application_type_for_position

  if @application_object.save
      # Mailer-Logik (Optional: Falls Mailer vorhanden sind)
      begin
        PositionApplicationMailer.submit_confirmation_to_user(@application_object).deliver_later
        PositionApplicationMailer.new_application_notification_to_organization(@application_object).deliver_later
      rescue => e
        Rails.logger.error "Mailer Error: #{e.message}"
      end

      redirect_to position_application_path(@position, @application_object), 
                  notice: t("applications.create.success.#{@position.type}", default: 'Erfolgreich gesendet!')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @application_object = Message.applications.find(params[:id])
  end

  private

  def set_position
    @position = Position.find(params[:position_id])
  end

  def initialize_application_object
    @application_object = Message.new
  end

  def application_type_for_position
    case @position.type
    when 'volunteering' then 'volunteer_application'
    when 'freetime'     then 'freetime_registration'
    when 'university_position' then 'assistant_application'
    end
  end

  def application_params
  case @position.type
  when 'volunteering'
    params.require(:message).permit(
      :first_name, :last_name, :email, :age, :gender,
      :preferred_language, # <-- NEU HINZUGEFÜGT
      :has_volunteer_experience, :volunteer_experience_description, :about_yourself
    )
  when 'freetime'
    params.require(:message).permit(
      :first_name, :last_name, :email, :age, :gender, :preferred_language, # <-- AUCH HIER
      :dietary_restrictions, :emergency_contact_name, :emergency_contact_phone, :additional_info
    )
  when 'university_position'
    params.require(:message).permit(
      :first_name, :last_name, :email, :age, :gender, :preferred_language, # <-- UND HIER
      :birth_date, :has_experience, :experience_description, :motivation, :about_yourself, :cv_file
    )
  end
  end
end