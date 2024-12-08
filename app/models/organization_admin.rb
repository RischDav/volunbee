class OrganizationAdmin < ApplicationRecord
  belongs_to :organization
  belongs_to :admin
end
