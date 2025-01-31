class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  enum :role, { user: 0, admin: 1 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :organization, optional: true
  attr_accessor :organization_name

  validate :organization_presence_for_user_role

  private

  def organization_presence_for_user_role
    if user? && organization.nil?
      errors.add(:organization, "must exist for users with role 'user'")
    elsif admin? && organization.present?
      errors.add(:organization, "must be blank for users with role 'admin'")
    end
  end
end
