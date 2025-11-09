class University < ApplicationRecord
  has_many :user_affiliations, dependent: :nullify
  has_many :users, through: :user_affiliations
  has_many :positions
  
  # Active Storage for file uploads
  has_one_attached :logo
  has_one_attached :cover_image
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validate :pictures_size
  validate :cover_image_format
  validate :logo_format

  private

  def pictures_size
    if logo.attached? && logo.blob.byte_size > 10.megabytes
      errors.add(:logo, "file should be less than 10MB")
    end
    if cover_image.attached? && cover_image.blob.byte_size > 10.megabytes
      errors.add(:cover_image, "file should be less than 10MB")
    end
  end

  def cover_image_format
    return unless cover_image.attached?

    unless cover_image.blob.content_type.in?(['image/jpeg', 'image/jpg', 'image/png', 'image/webp'])
      errors.add(:cover_image, 'must be a JPEG, PNG, or WebP image')
    end

    # Check if the filename suggests it's a logo
    filename = cover_image.blob.filename.to_s.downcase
    if filename.include?('logo') || filename.include?('icon')
      errors.add(:cover_image, "appears to be a logo file (#{cover_image.blob.filename}). Please upload a landscape photo or banner image for better display as a cover image")
    end
  end

  def logo_format
    return unless logo.attached?

    unless logo.blob.content_type.in?(['image/jpeg', 'image/jpg', 'image/png', 'image/webp'])
      errors.add(:logo, 'must be a JPEG, PNG, or WebP image')
    end
  end
end 