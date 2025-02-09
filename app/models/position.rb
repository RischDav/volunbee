class Position < ApplicationRecord
  has_many_attached :pictures
  belongs_to :organization

  validate :pictures_size
  validates :title, presence: true
  validates :title, length: { in: 10..30 }

  after_commit :process_pictures, on: [:create, :update]

  private

  def pictures_size
    pictures.each do |picture|
      if picture.blob.byte_size > 5.megabytes
        errors.add(:pictures, "each file should be less than 5MB")
      end
    end
  end

  def process_pictures
    pictures.each do |picture|
      ProcessPictureJob.perform_later(picture)
    end
  end
end