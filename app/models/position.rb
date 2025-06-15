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

  # Direkte S3-URL Helper-Methoden
  def direct_image_url(variant_options = nil)
    return nil unless main_picture.attached?
    
    begin
      if variant_options
        main_picture.variant(variant_options).processed.url
      else
        main_picture.url
      end
    rescue ActiveStorage::FileNotFoundError, ActiveStorage::IntegrityError
      nil
    end
  end

  def direct_thumbnail_url
    direct_image_url(resize_to_limit: [400, 250])
  end

  def direct_gallery_url
    direct_image_url(resize_to_fill: [600, 250])
  end

  def direct_logo_url
    direct_image_url(resize_to_fill: [112, 112])
  end

  # Für alle Bilder direkte URLs
  def all_direct_urls
    {
      main_picture: direct_image_url,
      thumbnail: direct_thumbnail_url,
      gallery: direct_gallery_url,
      logo: direct_logo_url,
      picture1: picture1.attached? ? picture1.url : nil,
      picture2: picture2.attached? ? picture2.url : nil,
      picture3: picture3.attached? ? picture3.url : nil
    }.compact
  end

  def picture_urls
    pictures = [:main_picture, :picture1, :picture2, :picture3]
    pictures.each_with_object({}) do |picture, urls|
      if send(picture).attached?
        begin
          urls[picture] = send(picture).url
        rescue ActiveStorage::FileNotFoundError
          urls[picture] = nil
        end
      end
    end.compact
  end

  def cache_key_with_version
    "#{super}-#{main_picture.attached? ? main_picture.blob&.checksum : 'no-image'}"
  end

  def image_url
    direct_image_url
  end

  def thumbnail_url
    direct_thumbnail_url
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