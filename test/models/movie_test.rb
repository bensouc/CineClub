require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "fixture movie is valid" do
    assert movies(:inception).valid?
  end

  test "is invalid without a title" do
    movie = movies(:inception)
    movie.title = nil
    assert_not movie.valid?
    assert_includes movie.errors[:title], "can't be blank"
  end

  test "is invalid without a poster_url" do
    movie = movies(:inception)
    movie.poster_url = nil
    assert_not movie.valid?
    assert_includes movie.errors[:poster_url], "can't be blank"
  end

  test "is invalid when another movie already uses the same tmdb_id" do
    duplicate = Movie.new(title: "Copie", poster_url: "https://example.test/p.jpg", tmdb_id: movies(:matrix).tmdb_id)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tmdb_id], "has already been taken"
  end

  test "destroying a movie destroys its choices" do
    movie = movies(:inception)
    assert_difference("Choice.count", -movie.choices.count) do
      movie.destroy
    end
  end

  test "find_or_create_from_tmdb returns the existing movie without calling TMDB" do
    assert_no_difference("Movie.count") do
      assert_equal movies(:matrix), Movie.find_or_create_from_tmdb(movies(:matrix).tmdb_id)
    end
    assert_not_requested :get, %r{themoviedb}
  end

  test "find_or_create_from_tmdb fetches and persists a movie it has never seen" do
    stub_tmdb_movie(550, trailer_key: "fc")

    movie = nil
    assert_difference("Movie.count", 1) do
      movie = Movie.find_or_create_from_tmdb(550)
    end

    assert movie.persisted?
    assert_equal "Fight Club", movie.title
    assert_equal 550, movie.tmdb_id
    assert_equal "Drame", movie.kind
    assert_equal "https://image.tmdb.org/t/p/w300/fightclub.jpg", movie.poster_url
    assert_equal "https://www.youtube.com/watch?v=fc", movie.trailer_url
    assert_equal Date.new(1999, 10, 15), movie.year
  end

  test "find_or_create_from_tmdb returns nil for an id TMDB does not know" do
    stub_tmdb_movie(424_242, body: { "status_message" => "Not found" }, status: 404)

    assert_no_difference("Movie.count") do
      assert_nil Movie.find_or_create_from_tmdb(424_242)
    end
  end

  test "find_or_create_from_tmdb propagates a TMDB outage" do
    stub_request(:get, %r{themoviedb}).to_timeout

    assert_raises(TmdbClient::Error) { Movie.find_or_create_from_tmdb(550) }
  end
end
