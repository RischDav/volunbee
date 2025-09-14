class UserAffiliation < ApplicationRecord
  belongs_to :user
  belongs_to :organization, optional: true
  belongs_to :university, optional: true

  # Einfache Konstanten statt enum
  NORMAL_USER = 0
  ADMIN = 1
  UNIVERSITY_STAFF = 2

  validates :role, inclusion: { in: [NORMAL_USER, ADMIN, UNIVERSITY_STAFF] }
  validate :affiliation_logic

  def normal_user?
    role == NORMAL_USER
  end

  def admin?
    role == ADMIN
  end

  def university_staff?
    role == UNIVERSITY_STAFF
  end

  private

  def affiliation_logic
    if admin?
      # Admins dürfen entweder einer Organisation ODER einer Universität angehören, aber nicht beiden
      if organization_id.present? && university_id.present?
        errors.add(:base, "Admins dürfen nicht gleichzeitig einer Organisation und einer Universität angehören")
      end
    elsif university_staff?
      # University Staff müssen einer Universität angehören
      if organization_id.present?
        errors.add(:base, "Universitätsmitarbeiter können nicht einer Organisation angehören")
      elsif university_id.blank?
        errors.add(:base, "Universitätsmitarbeiter müssen einer Universität angehören")
      end
    else
      # Normale User müssen genau eine Zugehörigkeit haben
      if organization_id.present? && university_id.present?
        errors.add(:base, "Ein User kann nicht gleichzeitig einer Organisation und einer Universität angehören")
      elsif organization_id.blank? && university_id.blank?
        errors.add(:base, "Ein normaler User muss entweder einer Organisation oder einer Universität angehören")
      end
    end
  end
end
