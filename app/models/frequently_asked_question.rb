class FrequentlyAskedQuestion < ApplicationRecord
  belongs_to :position
  
  validates :question, presence: true, length: { minimum: 5, maximum: 200 }
  validates :answer, presence: true, length: { minimum: 10, maximum: 1000 }
end
