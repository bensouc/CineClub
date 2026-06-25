require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:movie_night)
  end

  test "index requires authentication" do
    get events_path
    assert_redirected_to new_user_session_path
  end

  test "index renders for a signed-in user" do
    sign_in users(:alice)
    get events_path
    assert_response :success
  end

  test "show renders for a signed-in user" do
    sign_in users(:alice)
    get event_path(@event)
    assert_response :success
  end

  test "add_movie reuses an existing movie and adds it as a choice" do
    sign_in users(:alice)
    target = events(:empty_night) # has no choices yet, so the uniqueness rule is satisfied

    # tmdb_id 603 already exists (the matrix fixture), so find_or_create_movie
    # returns it without reaching out to the TMDB API.
    assert_difference("Choice.count", 1) do
      assert_no_difference("Movie.count") do
        post add_movie_path(target), params: {
          title: "The Matrix",
          tmdb_genre_id: "28",
          tmdb_poster_url: "/matrix.jpg",
          tmdb_id: "603",
          year: "1999-03-31",
          tmdb_overview: "A hacker learns the true nature of his reality."
        }
      end
    end

    assert_redirected_to event_path(target)
    assert_includes target.reload.movies, movies(:matrix)
  end
end
