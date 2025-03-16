class Organization < ApplicationRecord
    self.table_name = "organizations"
    has_one_attached :logo
    has_many :positions
    has_many :users

    validate :pictures_size
    after_commit :process_pictures, on: [:update]

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

