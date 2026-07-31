require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  SEARCH_BODY = {
    "results" => [
      {
        "id" => 603,
        "title" => "Matrix",
        "poster_path" => "/matrix.jpg",
        "release_date" => "1999-03-31"
      }
    ]
  }.freeze

  test "search requires authentication and never calls TMDB for anonymous users" do
    get movies_search_path(query: "matrix")

    assert_redirected_to new_user_session_path
    assert_not_requested :get, %r{themoviedb}
  end

  test "search returns normalised results as JSON" do
    stub_tmdb("search/movie", SEARCH_BODY)
    sign_in users(:alice)

    get movies_search_path(query: "matrix")

    assert_response :success
    results = response.parsed_body["results"]
    assert_equal 1, results.size
    assert_equal 603, results.first["tmdb_id"]
    assert_equal "https://image.tmdb.org/t/p/w300/matrix.jpg", results.first["poster_url"]
  end

  test "search never exposes the api key to the browser" do
    stub_tmdb("search/movie", SEARCH_BODY)
    sign_in users(:alice)

    get movies_search_path(query: "matrix")

    assert_response :success
    assert_not_includes response.body, Rails.application.credentials.dig(:tmdb, :api_key)
  end

  test "search answers 502 with a readable message when TMDB is down" do
    stub_request(:get, %r{themoviedb}).to_timeout
    sign_in users(:alice)

    get movies_search_path(query: "matrix")

    assert_response :bad_gateway
    assert_equal "La recherche est momentanément indisponible.", response.parsed_body["error"]
  end

  test "search returns an empty list for a blank query" do
    sign_in users(:alice)

    get movies_search_path(query: "")

    assert_response :success
    assert_equal [], response.parsed_body["results"]
    assert_not_requested :get, %r{themoviedb}
  end
end
