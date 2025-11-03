class Message < ApplicationRecord
  # Disable Single Table Inheritance since we use 'type' as a regular field
  self.inheritance_column = :_type_disabled
  
  belongs_to :position
  belongs_to :user, optional: true  # Allow guest messages
  
  # Validation for regular messages
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }, if: :regular_message?
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :regular_message?
  validates :sender_name, presence: true, length: { minimum: 2, maximum: 50 }, if: :regular_message?
  
  # Validations for applications
  validates :type, presence: true
  validates :first_name, presence: true, if: :application?
  validates :last_name, presence: true, if: :application?
  validates :birth_date, presence: true, if: :application?
  validates :phone_number, presence: true, if: :application?
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :application?
  
  scope :recent, -> { order(created_at: :desc) }
  scope :applications, -> { where(type: ['volunteer_application', 'freetime_registration', 'assistant_application']) }
  scope :regular_messages, -> { where(type: 'message') }
  
  before_create :set_sent_at
  
  def application?
    %w[volunteer_application freetime_registration assistant_application].include?(type)
  end
  
  def regular_message?
    type == 'message' || type.blank?
  end
  
  def application_data
    return {} unless application?
    
    {
      first_name: first_name,
      last_name: last_name,
      birth_date: birth_date,
      phone_number: phone_number,
      gender: gender,
      has_experience: has_experience,
      experience_description: experience_description,
      has_volunteer_experience: has_volunteer_experience,
      volunteer_experience_description: volunteer_experience_description,
      motivation: motivation,
      about_yourself: about_yourself
    }.compact
  end
  
  private
  
  def set_sent_at
    self.sent_at = Time.current
  end
end