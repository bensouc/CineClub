require "json"
require "open-uri"

class Movie < ApplicationRecord
  has_many :choices, dependent: :destroy

  validates :title, presence: true
  validates :poster_url, presence: true
  # validates :tmdb_id, uniqueness: true

  GENRES = [
    {
      id: 28,
      name: "Action",
    },
    {
      id: 12,
      name: "Aventure",
    },
    {
      id: 16,
      name: "Animation",
    },
    {
      id: 35,
      name: "Comédie",
    },
    {
      id: 80,
      name: "Crime",
    },
    {
      id: 99,
      name: "Documentaire",
    },
    {
      id: 18,
      name: "Drame",
    },
    {
      id: 10_751,
      name: "Familial",
    },
    {
      id: 14,
      name: "Fantastique",
    },
    {
      id: 36,
      name: "Histoire",
    },
    {
      id: 27,
      name: "Horreur",
    },
    {
      id: 10_402,
      name: "Musique",
    },
    {
      id: 9_648,
      name: "Mystère",
    },
    {
      id: 10_749,
      name: "Romance",
    },
    {
      id: 878,
      name: "Science-Fiction",
    },
    {
      id: 10_770,
      name: "Téléfilm",
    },
    {
      id: 53,
      name: "Thriller",
    },
    {
      id: 10_752,
      name: "Guerre",
    },
    {
      id: 37,
      name: "Western",
    },
  ]

  # CLASS METHOD
  def self.find_or_create_movie(ash)
    movie = Movie.where(tmdb_id: ash[:tmdb_id]).first
    if movie.nil?
      trailer = Movie.json_trailers(ash[:tmdb_id])
      unless trailer.nil?
        ash[:trailer_url] = "https://www.youtube.com/watch?v=#{trailer}"
      end
      kinds = ash[:kind].split(",")
      kinds_s = ""
      kinds.each do |kind_id|
        kinds_s = "#{kinds_s}#{GENRES.select { |a| a[:id] == kind_id.to_i }.first[:name]} "
      end
      ash[:kind] = kinds_s
      Movie.create(ash)
    else
      movie
    end
  end

  def self.json_trailers(tmdb_id)
    url = "http://api.themoviedb.org/3/movie/#{tmdb_id}/videos?api_key=5d25d045ccb74424de93b9f3878f1b6c"
    # url = "http://api.themoviedb.org/3/movie/#{tmdb_id}/videos?api_key=#{Movie::TMDB_API_KEY}"
    user_serialized = URI.open(url).read
    json = JSON.parse(user_serialized)
    if json["results"] == []
      return nil
    else
      return json["results"].first["key"]
    end
  end
end
