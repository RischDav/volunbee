class University < ApplicationRecord
  has_many :users
  has_many :positions
  has_many :students, dependent: :restrict_with_error
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end 