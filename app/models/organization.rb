class Organization < ApplicationRecord
    has_many :positions
    self.table_name = "organizations"
    has_one_attached :logo
    has_many :positions
    has_many :users

    validate :pictures_size
    after_commit :process_pictures, on: [:update]

    def complete_profile?
        # Prüfe, ob alle notwendigen Felder ausgefüllt sind
        name.present? && 
        email.present? && 
        contact_number.present? && 
        city.present? && 
        zip.present? && 
        street.present? && 
        housenumber.present? && 
        contact_person.present? && 
        description.present?
    end
      
    def incomplete_fields
        fields = []
        fields << "Name" unless name.present?
        fields << "E-Mail" unless email.present?
        fields << "Telefonnummer" unless contact_number.present?
        fields << "Stadt" unless city.present?
        fields << "Postleitzahl" unless zip.present?
        fields << "Straße" unless street.present?
        fields << "Hausnummer" unless housenumber.present?
        fields << "Beschreibung" unless description.present?
        fields << "Anprechperson" unless contact_person.present?
        fields
    end


    private

    def pictures_size
        if logo.attached? && logo.blob.byte_size > 5.megabytes
            errors.add(:logo, "file should be less than 5MB")
        end
    end

    def process_pictures
        ProcessPictureJob.set(wait: 5.seconds).perform_later(logo.blob.id) if logo.attached?
    end
end

