class Position < ApplicationRecord
  belongs_to :organization
  has_one_attached :mainPicture
  has_one_attached :picture1
  has_one_attached :picture2
  has_one_attached :picture3

  has_many :frequently_asked_questions, dependent: :destroy
  accepts_nested_attributes_for :frequently_asked_questions, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :mainPicture, presence: true
  validates :title, length: { in: 15..75 }
  validates :benefits, length: { in: 300..1000 }
  validates :description, length: { in: 300..1000 }
  validates :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validate :pictures_size

  after_commit :process_pictures, on: [:create, :update]

  def picture_urls
    pictures = [:mainPicture, :picture1, :picture2, :picture3]
    pictures.each_with_object({}) do |picture, urls|
      urls[picture] = Rails.application.routes.url_helpers.rails_blob_url(send(picture), only_path: true) if send(picture).attached?
    end
  end

  private

  def pictures_size
    [mainPicture, picture1, picture2, picture3].each do |picture|
      if picture.attached? && picture.blob.byte_size > 5.megabytes
        errors.add(:pictures, "each file should be less than 5MB")
      end
    end
  end

  def process_pictures
    [mainPicture, picture1, picture2, picture3].each do |picture|
      ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id) if picture.attached?
    end
  end
end