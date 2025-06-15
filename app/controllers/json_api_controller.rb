class JsonApiController < ApplicationController
  skip_before_action :authenticate_user!
  
  def output
    positions = Position.includes(:organization, :frequently_asked_questions, 
                                 main_picture_attachment: :blob,
                                 picture1_attachment: :blob,
                                 picture2_attachment: :blob,
                                 picture3_attachment: :blob)
                       .where(online: true, released: true)

    formatted_positions = positions.map do |position|
      organization = position.organization
      
      # Korrekte Attributnamen basierend auf dem Schema
      contact = {
        name: organization.contact_person.presence || "",
        email: organization.email.presence || "",
        phone: organization.contact_number.presence || "",
        website: organization.website.presence || ""
      }
      
      # Verwende direkte S3-URLs mit Fehlerbehandlung
      photos = {}
      if position.main_picture.attached?
        begin
          url = position.respond_to?(:direct_image_url) ? position.direct_image_url : position.main_picture.url
          photos[:photo1] = {
            url: url,
            author: ""
          } if url
        rescue ActiveStorage::FileNotFoundError => e
          Rails.logger.warn "Main picture not found for position #{position.id}: #{e.message}"
        rescue => e
          Rails.logger.error "Error generating main picture URL for position #{position.id}: #{e.message}"
        end
      end

      # Weitere Bilder sicher laden
      [position.picture1, position.picture2, position.picture3].each_with_index do |picture, index|
        if picture.attached?
          begin
            photos[:"photo#{index + 2}"] = {
              url: picture.url,
              author: ""
            }
          rescue ActiveStorage::FileNotFoundError => e
            Rails.logger.warn "Picture#{index + 1} not found for position #{position.id}: #{e.message}"
          rescue => e
            Rails.logger.error "Error generating picture#{index + 1} URL for position #{position.id}: #{e.message}"
          end
        end
      end

      # Logo sicher laden
      logo_url = nil
      if organization.logo.attached?
        begin
          logo_url = organization.logo.url
        rescue ActiveStorage::FileNotFoundError => e
          Rails.logger.warn "Logo not found for organization #{organization.id}: #{e.message}"
        rescue => e
          Rails.logger.error "Error generating logo URL for organization #{organization.id}: #{e.message}"
        end
      end

      {
        id: position.id,
        organization_name: organization.name || "",
        role: position.title || "",
        organization_code: organization.organization_code || "",  
        position_code: position.position_code || "",  
        position_temporary: position.position_temporary || false,
        organization_description: organization.description || "",
        tasks_description: position.description || "",
        benefits: position.benefits || "",
        contact: contact,
        faq: position.frequently_asked_questions.map do |faq|
          { 
            question: faq.question || "", 
            answer: faq.answer || "" 
          }
        end,
        materials: {
          logo: logo_url,
          photos: photos
        },
        ratings: {
          "Creative Skills": position.creative_skills || 0,
          "Technical Skills": position.technical_skills || 0,
          "Social Skills": position.social_skills || 0,
          "Language Skills": position.language_skills || 0,
          "Flexibility": position.flexibility || 0
        }
      }
    end

    render json: JSON.pretty_generate(formatted_positions)
  rescue => e
    Rails.logger.error "JSON API Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    render json: { 
      error: "Internal server error", 
      message: Rails.env.development? ? e.message : "Something went wrong"
    }, status: 500
  end
end