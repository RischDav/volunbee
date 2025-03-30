class PositionsController < ApplicationController
  before_action :authenticate_user!, except: [:json_output]
  before_action :set_position, only: [:show, :edit, :update, :destroy, :release, :lock, :delete_picture]

  def index
    if user_signed_in?
      if current_user.admin?
        @positions = Position.all
      else
        @positions = Position.where(organization_id: current_user.organization_id)
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
    @position.organization_id = current_user.organization_id
    @position.position_code = @position.title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '_')
  
    if @position.save
      [@position.mainPicture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
      end
      redirect_to positions_path, notice: "Position wurde erfolgreich erstellt."
      AdminMailer.new_position_email.deliver_later
    else
      # Benutzerfreundliche Fehlermeldungen generieren
      error_messages = []
      
      if @position.errors.include?(:title)
        if @position.title.blank?
          error_messages << "Der Titel darf nicht leer sein."
        else
          error_messages << "Der Titel muss zwischen 15 und 75 Zeichen lang sein (aktuell: #{@position.title.length} Zeichen)."
        end
      end
      
      if @position.errors.include?(:mainPicture)
        error_messages << "Ein Hauptbild muss hochgeladen werden."
      end
      
      if @position.errors.include?(:benefits)
        if @position.benefits.blank?
          error_messages << "Die Vorteile dürfen nicht leer sein."
        else
          error_messages << "Die Vorteile müssen zwischen 300 und 1000 Zeichen lang sein (aktuell: #{@position.benefits.length} Zeichen)."
        end
      end
      
      if @position.errors.include?(:description)
        if @position.description.blank?
          error_messages << "Die Beschreibung darf nicht leer sein."
        else
          error_messages << "Die Beschreibung muss zwischen 300 und 1000 Zeichen lang sein (aktuell: #{@position.description.length} Zeichen)."
        end
      end
      
      skill_namen = {
        creative_skills: "Kreative Fähigkeiten", 
        technical_skills: "Technische Fähigkeiten", 
        social_skills: "Soziale Fähigkeiten", 
        language_skills: "Sprachfähigkeiten", 
        flexibility: "Flexibilität"
      }
      
      skill_namen.each do |skill, name|
        if @position.errors.include?(skill)
          error_messages << "#{name} muss eine ganze Zahl zwischen 1 und 5 sein."
        end
      end
      
      if @position.errors.include?(:pictures)
        error_messages << "Die Bilder müssen kleiner als 5MB sein."
      end
      
      # Wenn keine detaillierten Fehler gefunden wurden, generische Meldung anzeigen
      if error_messages.empty?
        error_messages = @position.errors.full_messages
      end
      
      flash.now[:alert] = error_messages.join("<br><br> ->").html_safe
      render :new
    end
  end

  def edit
    AdminMailer.position_change_email.deliver_later
  end

  def json_output
    positions = Position.joins(:organization)
                     .where(released: true, online: true)
                     .where.not(
                       organizations: {
                         name: [nil, ""],
                         email: [nil, ""],
                         contact_number: [nil, ""],
                         city: [nil, ""],
                         zip: [nil, ""],
                         street: [nil, ""],
                         housenumber: [nil, ""],
                         description: [nil, ""]
                       }
                     )
    
    formatted_positions = positions.map do |position|
      organization = position.organization
      
      # Kontaktdaten: explizit null für fehlende Werte, mit existierenden Attributen
      contact = {
        name: organization.contact_person.presence || nil,  # Kein contact_person in Schema
        phone: organization.contact_number.presence || nil,
        email: organization.email.presence || nil,
        instagram: organization.instagram_url.presence || nil,
        facebook: organization.facebook_link.presence || nil,
        tiktok: organization.tiktok_url.presence || nil,  # Existiert nicht
        linkedin: organization.linkedin_url.presence || nil,
        x_account: nil,  # Existiert nicht
        website: organization.website.presence || nil,
        linktree: organization.linktree_url.presence || nil # Existiert nicht
      }
      
      # Fotos: Nur vorhandene Bilder in der richtigen Reihenfolge ausgeben
      photos = {}
      
      # mainPicture ist immer photo1, wenn vorhanden
      if position.mainPicture.attached?
        photos[:photo1] = {
          url: rails_blob_url(position.mainPicture, only_path: false),
          author: ""  # main_picture_author existiert nicht
        }
      end
      
      # Die anderen Bilder in der Reihenfolge hinzufügen
      photo_counter = 2
      [position.picture1, position.picture2, position.picture3].each_with_index do |picture, index|
        if picture.attached?
          photos[:"photo#{photo_counter}"] = {
            url: rails_blob_url(picture, only_path: false),
            author: ""  # picture_author Felder existieren nicht
          }
          photo_counter += 1
        end
      end
      
      {
        id: position.id,
        organization_code: organization.organization_code || "",  # code existiert nicht
        position_code: position.position_code || "",  # code existiert nicht
        position_temporary: position.position_temporary || "",  # temporary existiert nicht
        duration: "",  # duration existiert nicht
        weekly_time_commitment: position.weekly_time_commitment,  # weekly_time_commitment existiert nicht
        organization_name: organization.name || "",
        project_or_local_group: "",  # project_name existiert nicht
        role: position.title,
        organization_description: organization.description || "",
        tasks_description: position.description,
        benefits: position.benefits || "",
        faq: position.respond_to?(:frequently_asked_questions) ? 
             position.frequently_asked_questions.map do |faq|
               { question: faq.question, answer: faq.answer }
             end : [],
        address: {
          postal_code: organization.zip.presence || nil,  # postal_code → zip
          city: organization.city.presence || nil,
          street: organization.street.presence || nil,
          house_number: organization.housenumber.presence || nil,  # house_number → housenumber
          additional_info: nil  # Existiert nicht
        },
        contact: contact,
        materials: {
          authors: false,  # display_author_names existiert nicht
          logo: organization.respond_to?(:logo) && organization.logo.attached? ? 
                rails_blob_url(organization.logo, only_path: false) : nil,
          photos: photos
        },
        ratings: {
          "Creative Skills": position.creative_skills || 0,
          "Technical Skills": position.technical_skills || 0,
          "Social Skills": position.social_skills || 0,
          "Language Skills": position.language_skills || 0,
          "Flexibility": position.flexibility || 0
        },
        tags: []  # tags existiert nicht
      }
    end
  
    render json: JSON.pretty_generate(formatted_positions)
  end

  def show
  end

  def update
    if @position.update(position_params)
      [@position.mainPicture, @position.picture1, @position.picture2, @position.picture3].each do |picture|
        ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
      end
      redirect_to positions_path, notice: "Position was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @position.destroy
    redirect_to positions_path, notice: "Position was successfully deleted."
  end

  def release
    position = Position.find(params[:id])
    position.update(released: true)
    position.update(online: true)
    redirect_to positions_path, notice: 'Position wurde freigegeben.'
  end

  def offline
    position = Position.find(params[:id])
    position.update(online: false)
    redirect_to positions_path, notice: 'Position wurde offline gestellt.'
  end

  def online
    position = Position.find(params[:id])
    position.update(online: true)
    redirect_to positions_path, notice: 'Position wurde online gestellt.'
  end

  def lock
    position = Position.find(params[:id])
    position.update(released: false)
    position.update(online: false)
    redirect_to positions_path, notice: 'Position wurde gesperrt.'
  end

  def delete_picture
    picture_type = params[:picture_type]
    if @position.respond_to?(picture_type) && @position.send(picture_type).attached?
      @position.send(picture_type).purge
      redirect_to edit_position_path(@position), notice: "#{picture_type.humanize} wurde gelöscht."
    else
      redirect_to edit_position_path(@position), alert: "Bild konnte nicht gelöscht werden."
    end
  end

  private

  def set_position
    @position = Position.find(params[:id])
  end

  def position_params
    params.require(:position).permit(:title, :position_temporary, :weekly_time_commitment, :description, :benefits, :mainPicture, :picture1, :picture2, :picture3, :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility, :released, :online, frequently_asked_questions_attributes: [:id, :question, :answer, :_destroy])
  end
end