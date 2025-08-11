class University < ApplicationRecord
  has_many :user_affiliations, dependent: :nullify
  has_many :users, through: :user_affiliations
  has_many :positions
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end 