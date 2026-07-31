ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

# The suite must never reach TMDB (or anything else) for real: every outbound
# call is stubbed, and an unstubbed one should fail loudly rather than hang.
WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Matches any TMDB v3 endpoint regardless of the API key in the query string,
  # so the tests do not depend on the value stored in credentials.
  def stub_tmdb(path, body, status: 200)
    stub_request(:get, %r{\Ahttps://api\.themoviedb\.org/3/#{Regexp.escape(path)}\?})
      .to_return(
        status: status,
        body: body.is_a?(String) ? body : body.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  # The TMDB movie-details body the model and controller tests share.
  TMDB_MOVIE_BODY = {
    "id" => 550,
    "title" => "Fight Club",
    "poster_path" => "/fightclub.jpg",
    "release_date" => "1999-10-15",
    "overview" => "Un employé insomniaque fonde un club de combat.",
    "genres" => [{ "id" => 18, "name" => "Drame" }]
  }.freeze

  # Stubs the single call TmdbClient.movie_details makes; the trailer list rides
  # along in the same payload via append_to_response=videos.
  def stub_tmdb_movie(id = 550, body: TMDB_MOVIE_BODY, status: 200, trailer_key: nil)
    videos = trailer_key ? [{ "site" => "YouTube", "type" => "Trailer", "key" => trailer_key }] : []
    stub_tmdb("movie/#{id}", body.merge("videos" => { "results" => videos }), status: status)
  end
end

# Make Devise's `sign_in` / `sign_out` available in controller/integration tests.
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
