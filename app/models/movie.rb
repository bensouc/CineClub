class Movie < ApplicationRecord
  has_many :choices, dependent: :destroy

  

  validates :title, presence: true
  validates :kind, presence: true
  validates :poster_url, presence: true
  validates :trailer_url, presence: true
end
