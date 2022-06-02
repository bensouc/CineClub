class Movie < ApplicationRecord
  has_many :choices, dependent: :destroy

  validates :title, presence: true
  validates :poster_url, presence: true
  # validates :tmdb_id, uniqueness: true
end
