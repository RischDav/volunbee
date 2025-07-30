class University < ApplicationRecord
  has_many :users
  has_many :positions
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end 