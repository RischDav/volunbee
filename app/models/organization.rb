class Organization < ApplicationRecord
    self.table_name = "organizations"
    has_many :positions
    has_many :users
end
