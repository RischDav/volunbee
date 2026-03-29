class Message < ApplicationRecord
  self.inheritance_column = :_type_disabled
  
  belongs_to :position
  belongs_to :user, optional: true
  
  # Validierungen für alle Bewerbungstypen
  validates :type, presence: true
  validates :first_name, :last_name, :age, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Validierung für Volunteer-Erfahrungstext (nur wenn 'yes' ausgewählt)
  validates :volunteer_experience_description, presence: true, 
            if: -> { type == 'volunteer_application' && has_volunteer_experience == 'yes' }
  
  scope :applications, -> { where(type: ['volunteer_application', 'freetime_registration', 'assistant_application']) }
  
  before_create :set_sent_at
  
  private
  
  def set_sent_at
    self.sent_at = Time.current
  end
end