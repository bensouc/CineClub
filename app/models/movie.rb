class Movie < ApplicationRecord
  has_many :choices, dependent: :destroy

  validates :title, presence: true
  validates :poster_url, presence: true
  validates :tmdb_id, uniqueness: true, allow_nil: true

  # Returns the movie for this TMDB id, fetching it from the API the first time
  # we see it. Returns nil when TMDB does not know the id, and raises
  # TmdbClient::Error when the API itself is unreachable.
  def self.find_or_create_from_tmdb(tmdb_id)
    existing = find_by(tmdb_id: tmdb_id)
    return existing if existing

    attributes = TmdbClient.movie_details(tmdb_id)
    return nil if attributes.nil?

    create(attributes)
  end
end
