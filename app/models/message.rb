class Message < ApplicationRecord
  belongs_to :position
  belongs_to :user, optional: true  # Allow guest messages
  
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :sender_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :sender_name, presence: true, length: { minimum: 2, maximum: 50 }
  
  scope :recent, -> { order(created_at: :desc) }
  
  before_create :set_sent_at
  
  private
  
  def set_sent_at
    self.sent_at = Time.current
  end
end