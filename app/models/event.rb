class Event < ApplicationRecord
  # Assoziationen
  belongs_to :organization, optional: true
  belongs_to :user
  belongs_to :organization, optional: true
  belongs_to :user

  has_many :messages, dependent: :destroy
  
  # ActiveStorage für Bilder
  has_one_attached :main_picture
  has_one_attached :picture1
  has_one_attached :picture2
  has_one_attached :picture3
  
  # Validierungen
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  
  # Optional: Bilder-Größen validieren
  validate :main_picture_presence
  
  # Scopes
  
  scope :published, -> { where(released: true, online: true) }
  scope :upcoming, -> { where('start_date >= ?', Time.current).order(start_date: :asc) }
  scope :past, -> { where('end_date < ?', Time.current).order(start_date: :desc) }
  scope :ongoing, -> { where('start_date <= ? AND end_date >= ?', Time.current, Time.current) }
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, "muss nach dem Startdatum liegen")
    end
  end
  
  def main_picture_presence
    errors.add(:main_picture, "muss hochgeladen werden") unless main_picture.attached?
  end
end