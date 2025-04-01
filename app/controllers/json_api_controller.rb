class JsonApiController < ApplicationController
  # Überspringe Authentifizierung, wenn die JSON-Ausgabe öffentlich sein soll
  skip_before_action :authenticate_user!

  def output
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
      
      contact = {
        name: organization.contact_person.presence || nil,
        phone: organization.contact_number.presence || nil,
        email: organization.email.presence || nil,
        instagram: organization.instagram_url.presence || nil,
        facebook: organization.facebook_link.presence || nil,
        linkedin: organization.linkedin_url.presence || nil,
        website: organization.website.presence || nil
      }
      
      photos = {}
      if position.mainPicture.attached?
        photos[:photo1] = {
          url: rails_blob_url(position.mainPicture, only_path: false),
          author: ""
        }
      end

      [position.picture1, position.picture2, position.picture3].each_with_index do |picture, index|
        if picture.attached?
          photos[:"photo#{index + 2}"] = {
            url: rails_blob_url(picture, only_path: false),
            author: ""
          }
        end
      end

      {
        id: position.id,
        organization_name: organization.name || "",
        role: position.title,
        organization_description: organization.description || "",
        tasks_description: position.description,
        benefits: position.benefits || "",
        contact: contact,
        materials: {
          logo: organization.logo.attached? ? rails_blob_url(organization.logo, only_path: false) : nil,
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
