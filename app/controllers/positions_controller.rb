class PositionsController < ApplicationController
  before_action :authenticate_user!, except: [:json_output, :show]
  before_action :set_position, only: [:show, :edit, :update, :destroy, :release, :lock, :delete_picture]
  before_action :check_edit_permissions, only: [:edit, :update, :destroy]
  before_action :check_admin_permissions, only: [:release, :lock]
  before_action :check_online_offline_permissions, only: [:online, :offline]

  # Mapping für die Datenbank (da 'type' ein Integer ist)
  TYPE_MAPPING = { 'volunteering' => 1, 'freetime' => 2, 'university_position' => 3 }.freeze

  def index
    if user_signed_in?
      if current_user.admin?
        @positions = Position.all
      elsif current_user.organization?
        @positions = Position.where(organization_id: current_user.organization&.id)
      elsif current_user.student?
        @positions = Position.where(released: true, online: true)
      elsif current_user.university?
        @positions = Position.where(university_id: current_user.university&.id)
      else
        @positions = Position.none
      end
      @positions_count = @positions.size
    else
      @positions = nil
    end
  end

  def new
    @position = Position.new
    
    # Handle type-specific redirects
    if params[:type].present?
      case params[:type]
      when 'volunteering'
        @position.type = 'volunteering'
        render 'positions/volunteering/new' and return
      when 'freetime'
        @position.type = 'freetime'
        render 'positions/freetime/new' and return
      when 'university_position'
        @position.type = 'university_position'
        render 'positions/university_position/new' and return
      end
    end
  end

  def create
    pos_params = position_params

    # 1. URL Protokoll Fix (ergänzt https:// falls vergessen)
    if pos_params[:signup_page].present? && !pos_params[:signup_page].start_with?('http://', 'https://')
      pos_params[:signup_page] = "https://#{pos_params[:signup_page]}"
    end

    # 2. Typ-String in Integer umwandeln für die Datenbank (1, 2 oder 3)
    if pos_params[:type].present? && TYPE_MAPPING.key?(pos_params[:type])
      pos_params[:type] = TYPE_MAPPING[pos_params[:type]]
    end

    @position = Position.new(pos_params)

    # Set the appropriate ID based on user role
    if current_user.organization?
      @position.organization_id = current_user.organization&.id
    elsif current_user.university? || current_user.university_staff?
      @position.university_id = current_user.university&.id
    end

    @position.user_id = current_user.id
    @position.position_code = @position.title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '_') if @position.title.present?

    if @position.save
      [@position.main_picture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 5.seconds).perform_later(picture.blob.id) if picture.attached?
      end
  
      redirect_to positions_path, notice: "Position wurde erfolgreich erstellt."
      AdminMailer.new_position_email.deliver_later
    else
      # Deine originalen Fehlermeldungen
      error_messages = []
      if @position.errors[:base].include?("Maximum of 3 positions allowed per organization")
        error_messages << t('positions.errors.limit_reached')
      end
  
      if @position.errors.include?(:title)
        error_messages << (@position.title.blank? ? "Der Titel darf nicht leer sein." : "Der Titel muss zwischen 15 und 75 Zeichen lang sein.")
      end
  
      error_messages << "Ein Hauptbild muss hochgeladen werden." if @position.errors.include?(:main_picture)
      
      @position.errors.full_messages.each do |message|
        unless error_messages.any? { |error| error.include?(message) }
          error_messages << message
        end
      end
  
      flash.now[:alert] = error_messages.join("<br>").html_safe
      3.times { @position.frequently_asked_questions.build } if @position.frequently_asked_questions.empty?
      
      @position.online = true
      @position.is_active = true
      
      # Korrektes Template zurückgeben basierend auf Typ
      case params[:position][:type]
      when 'volunteering' then render 'positions/volunteering/new', status: :unprocessable_entity
      when 'freetime' then render 'positions/freetime/new', status: :unprocessable_entity
      when 'university_position' then render 'positions/university_position/new', status: :unprocessable_entity
      else render :new, status: :unprocessable_entity
      end
    end
  end

  def show
    if user_signed_in? && current_user.student?
      UserEvent.create!(user_type: :student, action_type: :view_position, position: @position, university: current_user.university)
    end
  end

  def edit
    AdminMailer.position_change_email.deliver_later
    render_edit_template
  end

  def update
    upd_params = position_params
    
    if upd_params[:signup_page].present? && !upd_params[:signup_page].start_with?('http://', 'https://')
      upd_params[:signup_page] = "https://#{upd_params[:signup_page]}"
    end

    if upd_params[:type].present? && TYPE_MAPPING.key?(upd_params[:type])
      upd_params[:type] = TYPE_MAPPING[upd_params[:type]]
    end

    if @position.update(upd_params)
      redirect_to positions_path, notice: "Position wurde erfolgreich aktualisiert."
    else
      render_edit_template(status: :unprocessable_entity)
    end
  end

  def destroy
    @position.destroy
    redirect_to positions_path, notice: "Position wurde erfolgreich gelöscht."
  end

  def release
    @position.update(released: true)
    redirect_to positions_path, notice: "Position wurde freigegeben."
  end

  def offline
    @position.update(online: false)
    redirect_to positions_path, notice: "Position wurde offline gesetzt."
  end

  def online
    @position.update(online: true)
    redirect_to positions_path, notice: "Position wurde online gesetzt."
  end

  def lock
    @position.update(released: false)
    redirect_to positions_path, notice: "Position wurde gesperrt."
  end

  def delete_picture
    picture_type = params[:picture_type]
    if @position.send(picture_type).attached?
      @position.send(picture_type).purge
      redirect_to edit_position_path(@position), notice: "Bild wurde erfolgreich gelöscht."
    else
      redirect_to edit_position_path(@position), alert: "Kein Bild zum Löschen gefunden."
    end
  end

  def json_output
    @positions = Position.where(released: true, online: true)
    render json: @positions
  end

  private

  def set_position
    @position = Position.includes(:frequently_asked_questions).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to positions_path, alert: "Position not found."
  end

  def check_edit_permissions
    unless can_edit_position?(@position)
      redirect_to positions_path, alert: 'Sie sind nicht berechtigt, diese Position zu bearbeiten.'
    end
  end

  def check_admin_permissions
    unless current_user.admin?
      redirect_to positions_path, alert: 'Nur Administratoren können Positionen freigeben oder sperren.'
    end
  end

  def check_online_offline_permissions
    unless can_edit_position?(@position)
      redirect_to positions_path, alert: 'Sie sind nicht berechtigt, den Status dieser Position zu ändern.'
    end
  end

  def can_edit_position?(position)
    return true if current_user.admin?
    if current_user.organization? && position.organization_id.present?
      return position.organization_id == current_user.organization&.id
    end
    if current_user.university_staff? && position.university_id.present?
      return position.university_id == current_user.university&.id
    end
    false
  end

  def position_params
    params.require(:position).permit(
      :title, :position_temporary, :weekly_time_commitment, :description, :benefits,
      :main_picture, :picture1, :picture2, :picture3,
      :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility,
      :released, :online, :visibility, :visible_university_id,
      :type, :appointment, :has_own_signup_page, :signup_page,
      :activity_type, :location, :schedule, :payment, # WICHTIG: Diese Felder müssen in die DB
      frequently_asked_questions_attributes: [:id, :question, :answer, :_destroy]
    )
  end

  def render_edit_template(status: nil)
    template_options = { status: status }.compact
    # Mapping zurück auf Strings für die Pfade
    type_string = case @position.type
                  when 1, 'volunteering' then 'volunteering'
                  when 2, 'freetime' then 'freetime'
                  when 3, 'university_position' then 'university_position'
                  end

    case type_string
    when 'volunteering' then render 'positions/volunteering/edit', **template_options
    when 'freetime' then render 'positions/freetime/edit', **template_options
    when 'university_position' then render 'positions/university_position/edit', **template_options
    else render :edit, **template_options
    end
  end
end