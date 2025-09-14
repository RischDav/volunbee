class PositionsController < ApplicationController
  before_action :authenticate_user!, except: [:json_output]
  before_action :set_position, only: [:show, :edit, :update, :destroy, :release, :lock, :delete_picture]

  def index
    if user_signed_in?
      if current_user.admin?
        @positions = Position.all
      elsif current_user.organization?
        @positions = Position.where(organization_id: current_user.organization&.id)
      elsif current_user.university?
        @positions = Position.where(university_id: current_user.university&.id)
      elsif current_user.student?
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
  end

  def create
    @position = Position.new(position_params)
    @position.user = current_user
    
    # Set the appropriate ID based on user role
    if current_user.organization?
      @position.organization_id = current_user.organization&.id
    elsif current_user.university?
      @position.university_id = current_user.university&.id
    end
    
    @position.position_code = @position.title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '_')
  
    if @position.save
      # Bilder verarbeiten
      [@position.main_picture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 5.seconds).perform_later(picture.blob.id) if picture.attached?
      end
  
      # Erfolgreiche Erstellung
      redirect_to positions_path, notice: "Position wurde erfolgreich erstellt."
      AdminMailer.new_position_email.deliver_later
    else
      # Benutzerfreundliche Fehlermeldungen generieren
      error_messages = []
  
      # Position Limit Error
      if @position.errors[:base].include?("Maximum of 3 positions allowed per organization")
        error_messages << t('positions.errors.limit_reached')
      end
  
      # Titel-Validierung
      if @position.errors.include?(:title)
        if @position.title.blank?
          error_messages << "Der Titel darf nicht leer sein."
        else
          error_messages << "Der Titel muss zwischen 15 und 75 Zeichen lang sein (aktuell: #{@position.title.length} Zeichen)."
        end
      end
  
      # Hauptbild-Validierung
      if @position.errors.include?(:main_picture)
        error_messages << "Ein Hauptbild muss hochgeladen werden."
      end
  
      # Vorteile-Validierung
      if @position.errors.include?(:benefits)
        if @position.benefits.blank?
          error_messages << t('positions.errors.benefits.blank')
        else
          error_messages << t('positions.errors.benefits.length', length: @position.benefits.length)
        end
      end
  
      # Beschreibung-Validierung
      if @position.errors.include?(:description)
        if @position.description.blank?
          error_messages << t('positions.errors.description.blank')
        else
          error_messages << t('positions.errors.description.length', length: @position.description.length)
        end
      end
  
      # Fähigkeiten-Validierung
      skill_namen = {
        creative_skills: t('positions.show.creative_skills'),
        technical_skills: t('positions.show.technical_skills'),
        social_skills: t('positions.show.social_skills'),
        language_skills: t('positions.show.language_skills'),
        flexibility: t('positions.show.flexibility')
      }
  
      skill_namen.each do |skill, name|
        if @position.errors.include?(skill)
          error_messages << t('positions.errors.skills.invalid', name: name)
        end
      end
  
      # Summe der Fähigkeiten prüfen
      skills_sum = skill_namen.keys.sum { |skill| @position.send(skill).to_i }
      if skills_sum > 15
        error_messages << t('positions.errors.skills.sum_exceeded', sum: skills_sum)
      end
  
      # Bilder-Validierung
      if @position.errors.include?(:pictures)
        error_messages << t('positions.errors.pictures.too_large')
      end
  
      # Andere Validierungsfehler
      @position.errors.full_messages.each do |message|
        unless error_messages.any? { |error| error.include?(message) }
          error_messages << message
        end
      end
  
      # Fehler anzeigen
      flash.now[:alert] = error_messages.join("<br>").html_safe
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Position details view
  end

  def edit
    AdminMailer.position_change_email.deliver_later
  end

  def update
    if @position.update(position_params)
      redirect_to positions_path, notice: "Position wurde erfolgreich aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @position.destroy
    redirect_to positions_path, notice: "Position wurde erfolgreich gelöscht."
  end

  def release
    position = Position.find(params[:id])
    position.update(released: true)
    redirect_to positions_path, notice: "Position wurde freigegeben."
  end

  def offline
    position = Position.find(params[:id])
    position.update(online: false)
    redirect_to positions_path, notice: "Position wurde offline gesetzt."
  end

  def online
    position = Position.find(params[:id])
    position.update(online: true)
    redirect_to positions_path, notice: "Position wurde online gesetzt."
  end

  def lock
    position = Position.find(params[:id])
    position.update(released: false)
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
    @position = Position.find(params[:id])
  end

  def position_params
    params.require(:position).permit(
      :title, :description, :benefits, :weekly_time_commitment, :position_temporary,
      :main_picture, :creative_skills, :technical_skills, :social_skills,
      :language_skills, :flexibility,
      frequently_asked_questions_attributes: [:id, :question, :answer, :_destroy]
    )
  end
end