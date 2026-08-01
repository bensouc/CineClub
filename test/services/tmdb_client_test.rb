require "test_helper"

class TmdbClientTest < ActiveSupport::TestCase
  SEARCH_BODY = {
    "results" => [
      {
        "id" => 603,
        "title" => "Matrix",
        "original_title" => "The Matrix",
        "poster_path" => "/matrix.jpg",
        "release_date" => "1999-03-31",
        "genre_ids" => [28, 878],
        "overview" => "Un pirate informatique découvre la vraie nature du réel."
      },
      {
        # No poster: unusable in a poster grid, and Movie requires a poster_url.
        "id" => 999,
        "title" => "Sans affiche",
        "poster_path" => nil,
        "release_date" => "2001-01-01"
      }
    ]
  }.freeze

  # movie_details asks for the trailers in the same call via
  # append_to_response=videos, so they arrive nested in the details payload.
  DETAILS_BODY = {
    "id" => 603,
    "title" => "Matrix",
    "poster_path" => "/matrix.jpg",
    "release_date" => "1999-03-31",
    "overview" => "Un pirate informatique découvre la vraie nature du réel.",
    "genres" => [{ "id" => 28, "name" => "Action" }, { "id" => 878, "name" => "Science-Fiction" }],
    "videos" => {
      "results" => [
        { "site" => "YouTube", "type" => "Featurette", "key" => "featurette" },
        { "site" => "YouTube", "type" => "Trailer", "key" => "trailerkey" }
      ]
    },
    "credits" => {
      "crew" => [
        { "job" => "Writer", "name" => "Someone Else" },
        { "job" => "Director", "name" => "Lana Wachowski" },
        { "job" => "Director", "name" => "Lilly Wachowski" }
      ]
    }
  }.freeze

  VIDEOS_BODY = {
    "id" => 603,
    "results" => [
      { "site" => "YouTube", "type" => "Featurette", "key" => "featurette" },
      { "site" => "YouTube", "type" => "Trailer", "key" => "trailerkey" }
    ]
  }.freeze

  # --- search ---------------------------------------------------------------

  test "search returns poster-bearing results with absolute poster urls" do
    stub_tmdb("search/movie", SEARCH_BODY)

    results = TmdbClient.search("matrix")

    assert_equal 1, results.size, "the posterless result should be dropped"
    assert_equal 603, results.first[:tmdb_id]
    assert_equal "Matrix", results.first[:title]
    assert_equal "https://image.tmdb.org/t/p/w300/matrix.jpg", results.first[:poster_url]
    assert_equal "1999", results.first[:year]
  end

  test "search sends the query and the credentials api key over https" do
    stub_tmdb("search/movie", SEARCH_BODY)

    TmdbClient.search("matrix")

    assert_requested :get, %r{\Ahttps://api\.themoviedb\.org/3/search/movie\?} do |request|
      params = CGI.parse(request.uri.query)
      params["query"] == ["matrix"] &&
        params["language"] == ["fr"] &&
        params["api_key"] == [Rails.application.credentials.dig(:tmdb, :api_key)]
    end
  end

  test "search short-circuits on a blank query without calling TMDB" do
    assert_equal [], TmdbClient.search("")
    assert_equal [], TmdbClient.search("   ")
    assert_equal [], TmdbClient.search(nil)
    assert_not_requested :get, %r{themoviedb}
  end

  test "search raises a TmdbClient::Error on an API error response" do
    stub_tmdb("search/movie", { "status_message" => "Invalid API key" }, status: 401)

    error = assert_raises(TmdbClient::Error) { TmdbClient.search("matrix") }
    assert_match "401", error.message
  end

  test "search raises a TmdbClient::Error when the connection times out" do
    stub_request(:get, %r{themoviedb}).to_timeout

    assert_raises(TmdbClient::Error) { TmdbClient.search("matrix") }
  end

  test "search raises a TmdbClient::Error on an unparseable body" do
    stub_tmdb("search/movie", "<html>nope</html>")

    assert_raises(TmdbClient::Error) { TmdbClient.search("matrix") }
  end

  # --- movie_details --------------------------------------------------------

  test "movie_details maps a TMDB movie onto Movie attributes" do
    stub_tmdb("movie/603", DETAILS_BODY)

    details = TmdbClient.movie_details(603)

    assert_equal 603, details[:tmdb_id]
    assert_equal "Matrix", details[:title]
    assert_equal "https://image.tmdb.org/t/p/w300/matrix.jpg", details[:poster_url]
    assert_equal "1999-03-31", details[:year]
    assert_equal "https://www.youtube.com/watch?v=trailerkey", details[:trailer_url]
    assert_equal "Lana Wachowski", details[:director], "the first credited director wins"
  end

  test "movie_details uses the genre names TMDB already localised" do
    stub_tmdb("movie/603", DETAILS_BODY)

    assert_equal "Action, Science-Fiction", TmdbClient.movie_details(603)[:kind]
  end

  test "movie_details fetches the trailer in the same request as the details" do
    stub_tmdb("movie/603", DETAILS_BODY)

    TmdbClient.movie_details(603)

    assert_requested :get, %r{/3/movie/603\?}, times: 1 do |request|
      CGI.parse(request.uri.query)["append_to_response"] == ["videos,credits"]
    end
    assert_not_requested :get, %r{/3/movie/603/videos}
  end

  test "movie_details returns nil for an unknown id" do
    stub_tmdb("movie/1", { "status_message" => "Not found" }, status: 404)

    assert_nil TmdbClient.movie_details(1)
  end

  test "movie_details returns nil for a non-numeric id without calling TMDB" do
    assert_nil TmdbClient.movie_details("not-an-id")
    assert_nil TmdbClient.movie_details(nil)
    assert_not_requested :get, %r{themoviedb}
  end

  # --- trailer_url ----------------------------------------------------------

  test "trailer_url prefers a YouTube trailer over other video types" do
    stub_tmdb("movie/603/videos", VIDEOS_BODY)

    assert_equal "https://www.youtube.com/watch?v=trailerkey", TmdbClient.trailer_url(603)
  end

  test "trailer_url ignores videos hosted outside YouTube" do
    stub_tmdb("movie/603/videos", { "results" => [{ "site" => "Vimeo", "type" => "Trailer", "key" => "x" }] })

    assert_nil TmdbClient.trailer_url(603)
  end

  test "trailer_url returns nil rather than raising when TMDB fails" do
    stub_tmdb("movie/603/videos", { "status_message" => "boom" }, status: 500)

    assert_nil TmdbClient.trailer_url(603)
  end

  # --- configuration --------------------------------------------------------

  test "a missing api key raises a TmdbClient::Error instead of calling TMDB" do
    credentials = Rails.application.credentials
    credentials.stub(:dig, nil) do
      error = assert_raises(TmdbClient::Error) { TmdbClient.search("matrix") }
      assert_match(/api key/i, error.message)
    end
    assert_not_requested :get, %r{themoviedb}
  end
end
