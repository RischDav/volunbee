class UserAffiliation < ApplicationRecord
  belongs_to :user
  belongs_to :organization, optional: true
  belongs_to :university, optional: true

  # Einfache Konstanten statt enum
  NORMAL_USER = 0
  ADMIN = 1

  validates :role, inclusion: { in: [NORMAL_USER, ADMIN] }
  validate :affiliation_logic

  def normal_user?
    role == NORMAL_USER
  end

  def admin?
    role == ADMIN
  end

  private

  def affiliation_logic
    if admin?
      # Admins dürfen weder Organization noch University haben
      if organization_id.present? || university_id.present?
        errors.add(:base, "Admins dürfen weder einer Organisation noch einer Universität angehören")
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
