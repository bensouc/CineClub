class Movie < ApplicationRecord
  has_many :choices, dependent: :destroy

  validates :title, presence: true
  validates :kind
  validates :poster_url, presence: true
  validates :trailer_url
  validates :tmdb_id, uniqueness: true
end
