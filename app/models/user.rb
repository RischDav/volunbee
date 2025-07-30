class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  enum :role, { organization: 0, admin: 1, university: 2, student: 3 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  belongs_to :organization, optional: true
  belongs_to :university, optional: true
  attr_accessor :organization_name, :university_name

  validate :organization_presence_for_organization_role
  validate :university_presence_for_university_role
  validate :university_presence_for_student_role
  validate :no_organization_for_admin_role
  validate :no_university_for_admin_role
  validate :no_university_for_organization_role
  validate :no_organization_for_university_role
  validate :no_organization_for_student_role

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
    return nil unless student?
    
    if email.end_with?('@tum.de') || email.end_with?('@mytum.de')
      University.find_by(name: 'Technische Universität München')
    elsif email.end_with?('@hs-heilbronn.de')
      University.find_by(name: 'Hochschule Heilbronn')
    end
  end
  
  private

  def organization_presence_for_organization_role
    if organization? && organization.nil?
      errors.add(:organization, "must exist for users with role 'organization'")
    end
  end

  def university_presence_for_university_role
    if university? && university.nil?
      errors.add(:university, "must exist for users with role 'university'")
    end
  end

  def university_presence_for_student_role
    if student? && university.nil?
      errors.add(:university, "must exist for users with role 'student'")
    end
  end

  def no_organization_for_admin_role
    if admin? && organization.present?
      errors.add(:organization, "must be blank for users with role 'admin'")
    end
  end

  def no_university_for_admin_role
    if admin? && university.present?
      errors.add(:university, "must be blank for users with role 'admin'")
    end
  end

  def no_university_for_organization_role
    if organization? && university.present?
      errors.add(:university, "must be blank for users with role 'organization'")
    end
  end

  def no_organization_for_university_role
    if university? && organization.present?
      errors.add(:organization, "must be blank for users with role 'university'")
    end
  end

  def no_organization_for_student_role
    if student? && organization.present?
      errors.add(:organization, "must be blank for users with role 'student'")
    end
  end
end