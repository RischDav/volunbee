class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  enum :role, { user: 0, admin: 1 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  belongs_to :organization, optional: true
  attr_accessor :organization_name

  validate :organization_presence_for_user_role

  # Überschreibt Devise's Standardverhalten für die Authentifizierung
  # Ein User kann sich einloggen, wenn er bestätigt ist
  def active_for_authentication?
    # Für Admins keine Beschränkungen
    return true if admin?
    
    # Für normale User: nur Email-Bestätigung prüfen
    super
  end

  # Diese Methode bestimmt die Nachricht, die angezeigt wird,
  # wenn ein User sich nicht einloggen kann
  def inactive_message
    if !confirmed?
      :unconfirmed
    else
      super
    end
  end

  # Neue Methode zur Prüfung, ob der User vollen Zugriff haben soll
  # Voller Zugriff bedeutet: Email bestätigt oder Admin-Rechte
  def full_access?
    admin? || confirmed?
  end

  # Prüft, ob der Nutzer auf besondere Informationen zugreifen darf
  def restricted_access?
    !confirmed?
  end
  
  private

  def organization_presence_for_user_role
    if user? && organization.nil?
      errors.add(:organization, "must exist for users with role 'user'")
    elsif admin? && organization.present?
      errors.add(:organization, "must be blank for users with role 'admin'")
    end
  end
end