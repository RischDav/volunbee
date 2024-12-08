class Position < ApplicationRecord
  has_many :images
  belongs_to :organization
end
