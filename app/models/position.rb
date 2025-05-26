class Position < ApplicationRecord
  # Each position belongs to an organization
  belongs_to :organization

  # Each position can have multiple images
  has_one_attached :main_picture
  has_one_attached :picture1
  has_one_attached :picture2
  has_one_attached :picture3

  # Each position can have multiple questions and answers
  has_many :frequently_asked_questions, dependent: :destroy
  accepts_nested_attributes_for :frequently_asked_questions, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :title, presence: true, length: { in: 15..75 }
  validates :benefits, length: { in: 100..1000 }
  validates :description, length: { in: 100..1000 }
  validates :main_picture, presence: true
  validates :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility, 
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validate :pictures_size
  validate :organization_position_limit

  after_commit :process_pictures, on: [:create, :update]

  def picture_urls
    pictures = [:main_picture, :picture1, :picture2, :picture3]
    pictures.each_with_object({}) do |picture, urls|
      urls[picture] = Rails.application.routes.url_helpers.rails_blob_url(send(picture), only_path: true) if send(picture).attached?
    end
  end

  def cache_key_with_version
    "#{super}-#{main_picture.attached? ? main_picture.blob&.checksum : 'no-image'}"
  end

  def image_url
    if main_picture.attached?
      Rails.application.routes.url_helpers.rails_blob_url(main_picture)
    end
  end

  def thumbnail_url
    if main_picture.attached?
      Rails.application.routes.url_helpers.rails_representation_url(
        main_picture.variant(resize_to_fill: [300, 300]).processed
      )
    end
  end

  private

  def pictures_size
    [main_picture, picture1, picture2, picture3].each do |picture|
      if picture.attached? && picture.blob.byte_size > 10.megabytes
        errors.add(:pictures, "each file should be less than 10 Megabytes")
      end
    end
  end

  def organization_position_limit
    if organization && organization.positions.count >= 3 && new_record?
      errors.add(:base, "Maximum of 3 positions allowed per organization")
    end
  end

  def process_pictures
    [main_picture, picture1, picture2, picture3].each do |picture|
      ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
    end
  end
end

# Run this in your terminal:
# rails console
#
# Then paste and run:
# Position.find_each do |position|
#   puts "Position: #{position.title}"
#   position.picture_urls.each do |key, url|
#     puts "  #{key}: #{url}"
#   end
# end