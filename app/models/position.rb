class Position < ApplicationRecord
  has_many_attached :pictures
  belongs_to :organization

  validate :pictures_size

  private

  def pictures_size
    pictures.each do |picture|
      if picture.blob.byte_size > 5.megabytes
        errors.add(:pictures, "each file should be less than 5MB")
      end
    end
  end
end
