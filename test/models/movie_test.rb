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

  test "destroying a movie destroys its choices" do
    movie = movies(:inception)
    assert_difference("Choice.count", -movie.choices.count) do
      movie.destroy
    end
  end

  test "GENRES exposes tmdb genre ids and names" do
    drama = Movie::GENRES.find { |g| g[:id] == 18 }
    assert_equal "Drame", drama[:name]
  end
end
