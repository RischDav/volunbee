# app/models/message.rb
class Message < ApplicationRecord
  # Deaktiviere Single-Table Inheritance (STI)
  self.inheritance_column = nil

  belongs_to :position, optional: true
  belongs_to :event, optional: true
  belongs_to :user

  # Validierung: Entweder position oder event muss vorhanden sein
  validate :must_have_position_or_event

  # Scopes für verschiedene Typen
  scope :applications, -> { where(type: ['volunteer_application', 'freetime_registration', 'assistant_application']) }
  scope :event_registrations, -> { where(type: 'event_registration') }

  private

  def must_have_position_or_event
    if position_id.blank? && event_id.blank?
      errors.add(:base, "Die Nachricht muss entweder einer Position oder einem Event zugeordnet sein")
    end
  end
end