class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Neue Beziehung zur UserAffiliation
  has_one :affiliation, class_name: "UserAffiliation", dependent: :destroy
  
  # Für Kompatibilität mit bestehenden Formularen
  attr_accessor :organization_name, :university_name

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

  # Determine university based on email domain for students
  def determine_university_from_email
    if email.end_with?('@tum.de') || email.end_with?('@mytum.de')
      University.find_by(name: 'Technische Universität München')
    elsif email.end_with?('@hs-heilbronn.de')
      University.find_by(name: 'Hochschule Heilbronn')
    end
  end

  # Kompatibilitäts-Helper für die alte API
  def organization
    affiliation&.organization
  end

  def university
    affiliation&.university
  end

  def admin?
    affiliation&.admin? || false
  end

  def organization?
    affiliation&.organization_id.present?
  end

  def university?
    affiliation&.university_id.present?
  end

  def student?
    university?
  end

  # Neue Helper-Methoden
  def platform_admin?
    admin? && affiliation&.organization_id.blank? && affiliation&.university_id.blank?
  end

  def normal_user?
    affiliation&.normal_user? || false
  end
end