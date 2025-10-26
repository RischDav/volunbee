class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_status
  before_action :set_public_layout
  
  def imprint
  end

  def privacy
  end

  # Freetime Methoden (bereits vorhanden)
  def new_freetime_position
    @organization = Organization.new
    @position = Position.new
    @position.type = 'freetime'
  end

  def create_freetime_position
    create_position('freetime')
  end

  # Neue Volunteering Methoden
  def new_volunteering_position
    @organization = Organization.new
    @position = Position.new
    @position.type = 'volunteering'
  end

  def create_volunteering_position
    create_position('volunteering')
  end

  def success_freetime_position
    # Erfolgsseite (für beide Typen verwendet)
  end

  def success_volunteering_position
    # Erfolgsseite für Volunteering
  end

  def position_submitted
    # Allgemeine Erfolgsseite für alle Position-Typen
  end

  private

  def set_public_layout
    @custom_navbar = true
  end

  def create_position(position_type)
    # Parameter verarbeiten - jetzt aus der verschachtelten Struktur
    all_params = params.require(:position).permit(
      :title, :description, :benefits, :weekly_time_commitment,
      :position_temporary, :payment,
      :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility,
      :main_picture, :picture1, :picture2, :picture3,
      organization: [
        :name, :email, :contact_person, :contact_number, :description,
        :city, :zip, :street, :housenumber, :website,
        :instagram_url, :linkedin_url, :facebook_link, :tiktok_url, :linktree_url,
        :logo
      ]
    )
    
    org_params = all_params[:organization]
    pos_params = all_params.except(:organization)
    
    # Organisation erstellen
    @organization = Organization.new(org_params)
    @organization.released = false # Muss erst genehmigt werden
    
    if @organization.save
      # Position erstellen ohne User (für öffentliche Einreichungen)
      @position = Position.new(pos_params)
      @position.organization = @organization
      @position.user = nil  # No user for public submissions
      @position.type = position_type
      @position.released = false # Muss erst genehmigt werden
      @position.online = false
      @position.position_code = @position.title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '_')
      
      if @position.save
        # Bilder verarbeiten
        [@position.main_picture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
          ProcessPictureJob.set(wait: 5.seconds).perform_later(picture.blob.id) if picture.attached?
        end

        # E-Mails versenden
        begin
          # An die Organisation
          OrganizationMailer.position_submitted(@organization, @position).deliver_later
          
          # An die Admins
          AdminMailer.new_organization_and_position(@organization, @position).deliver_later
        rescue => e
          Rails.logger.error "Failed to send emails: #{e.message}"
        end
        
        success_path = position_submitted_path
        redirect_to success_path, notice: 'Ihre Position wurde erfolgreich eingereicht! Sie erhalten in Kürze eine Bestätigungs-E-Mail.'
      else
        Rails.logger.error "Position validation errors: #{@position.errors.full_messages}"
        # WICHTIG: Organisation löschen aber Position-Fehler BEHALTEN
        @organization.destroy
        # KEINE neue Position erstellen - die alte behalten mit den Fehlern!
        @position.organization = Organization.new(org_params) # Für das Form
        render_form_for_type(position_type)
      end
    else
      Rails.logger.error "Organization validation errors: #{@organization.errors.full_messages}"
      # Position für das Form erstellen aber ohne Validierung
      @position = Position.new(pos_params)
      @position.type = position_type
      render_form_for_type(position_type)
    end
  rescue => e
    Rails.logger.error "Error creating #{position_type} position: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:alert] = 'Es ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.'
    
    # Safe fallback für Parameter
    begin
      all_params = params.require(:position).permit(
        :title, :description, :benefits, :weekly_time_commitment,
        :position_temporary, :payment,
        :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility,
        :main_picture, :picture1, :picture2, :picture3,
        organization: [
          :name, :email, :contact_person, :contact_number, :description,
          :city, :zip, :street, :housenumber, :website,
          :instagram_url, :linkedin_url, :facebook_link, :tiktok_url, :linktree_url,
          :logo
        ]
      )
      org_params = all_params[:organization] || {}
      pos_params = all_params.except(:organization)
    rescue
      org_params = {}
      pos_params = {}
    end
    
    @organization ||= Organization.new(org_params)
    @position ||= Position.new(pos_params)
    @position.type = position_type
    render_form_for_type(position_type)
  end

  def render_form_for_type(position_type)
    case position_type
    when 'freetime'
      render :new_freetime_position, status: :unprocessable_entity
    when 'volunteering'
      render :new_volunteering_position, status: :unprocessable_entity
    end
  end
end