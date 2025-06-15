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
      
      contact = {
        name: organization.contact_person_name.presence || "",
        email: organization.contact_email.presence || "",
        phone: organization.contact_phone.presence || "",
        website: organization.website.presence || nil
      }
      
      # Verwende direkte S3-URLs
      photos = {}
      if position.main_picture.attached? && (url = position.direct_image_url)
        photos[:photo1] = {
          url: url,
          author: ""
        }
      end

      [position.picture1, position.picture2, position.picture3].each_with_index do |picture, index|
        if picture.attached?
          begin
            photos[:"photo#{index + 2}"] = {
              url: picture.url,
              author: ""
            }
          rescue ActiveStorage::FileNotFoundError
            # Überspringe fehlerhafte Bilder
          end
        end
      end

      {
        id: position.id,
        organization_name: organization.name || "",
        role: position.title,
        organization_code: organization.organization_code || "",  
        position_code: position.position_code || "",  
        position_temporary: position.position_temporary || "",
        organization_description: organization.description || "",
        tasks_description: position.description,
        benefits: position.benefits || "",
        contact: contact,
        faq: position.frequently_asked_questions.map do |faq|
          { question: faq.question, answer: faq.answer }
        end,
        materials: {
          logo: organization.logo.attached? ? organization.logo.url : nil,
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
  end
end