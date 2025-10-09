class UserEvent < ApplicationRecord
  belongs_to :university, optional: true
  belongs_to :organization, optional: true
  belongs_to :position, optional: true

  enum :action_type, {
    contacted_organization: 0,
    logged_in: 1,
    view_position: 2,
    sign_up: 3
  }
  enum :user_type, {
    student: 0,
    admin: 1,
    university_staff: 2,
    organization_staff: 3
  }
end
