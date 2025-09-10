class University < ApplicationRecord
  has_many :user_affiliations, dependent: :nullify
  has_many :users, through: :user_affiliations
  has_many :positions
  
  # Active Storage for file uploads
  has_one_attached :logo
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end 