require "test_helper"

class ChoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:movie_night)
    @empty_event = events(:empty_night)   # no choices yet, so adding one is allowed
    @inception_choice = choices(:inception_choice) # alice already voted for this one
    @matrix_choice = choices(:matrix_choice)       # nobody voted for this one yet
  end

  test "voting requires authentication" do
    post event_vote_path(event_id: @event.id, id: @matrix_choice.id)
    assert_redirected_to new_user_session_path
  end

  test "voting creates a vote and refreshes the ranking" do
    sign_in users(:alice)

    assert_difference("Vote.count", 1) do
      post event_vote_path(event_id: @event.id, id: @matrix_choice.id)
    end

    assert_redirected_to event_path(@event)
    @matrix_choice.reload
    assert_equal @matrix_choice.votes.count, @matrix_choice.ranking
  end

  test "voting twice for the same choice does not create a duplicate" do
    sign_in users(:alice)

    assert_no_difference("Vote.count") do
      post event_vote_path(event_id: @event.id, id: @inception_choice.id)
    end
    assert_redirected_to event_path(@event)
  end

  test "unvoting destroys the user's vote and refreshes the ranking" do
    sign_in users(:alice)

    assert_difference("Vote.count", -1) do
      delete event_unvote_path(event_id: @event.id, id: @inception_choice.id)
    end

    assert_redirected_to event_path(@event)
    @inception_choice.reload
    assert_equal @inception_choice.votes.count, @inception_choice.ranking
  end

  test "destroying a choice removes it along with its votes" do
    sign_in users(:alice)

    assert_difference("Choice.count", -1) do
      assert_difference("Vote.count", -@inception_choice.votes.count) do
        delete choice_path(@inception_choice)
      end
    end
    assert_redirected_to event_path(@event)
  end

  # --- adding a movie to an event (ChoicesController#create) ----------------

  test "creating a choice requires authentication" do
    post event_choices_path(@empty_event), params: { tmdb_id: 550 }

    assert_redirected_to new_user_session_path
    assert_not_requested :get, %r{themoviedb}
  end

  test "creating a choice reuses a known movie without calling TMDB" do
    sign_in users(:alice)

    assert_difference("Choice.count", 1) do
      assert_no_difference("Movie.count") do
        post event_choices_path(@empty_event), params: { tmdb_id: movies(:matrix).tmdb_id }
      end
    end

    assert_redirected_to event_path(@empty_event)
    assert_includes @empty_event.reload.movies, movies(:matrix)
    assert_not_requested :get, %r{themoviedb}
  end

  test "creating a choice fetches an unknown movie from TMDB and adds it as a choice" do
    stub_tmdb_movie(550, trailer_key: "fc")
    sign_in users(:alice)

    assert_difference(["Choice.count", "Movie.count"], 1) do
      post event_choices_path(@empty_event), params: { tmdb_id: 550 }
    end

    assert_redirected_to event_path(@empty_event)
    movie = Movie.find_by(tmdb_id: 550)
    assert_equal "Fight Club", movie.title
    # The genre names must survive: the old code overwrote them with raw ids.
    assert_equal "Drame", movie.kind
    assert_includes @empty_event.reload.movies, movie
  end

  test "creating a choice ignores movie details supplied by the client" do
    stub_tmdb_movie(550)
    sign_in users(:alice)

    post event_choices_path(@empty_event), params: {
      tmdb_id: 550,
      title: "Titre falsifié",
      tmdb_overview: "<script>alert(1)</script>",
      tmdb_poster_url: "https://evil.test/p.jpg"
    }

    movie = Movie.find_by(tmdb_id: 550)
    assert_equal "Fight Club", movie.title
    assert_equal "https://image.tmdb.org/t/p/w300/fightclub.jpg", movie.poster_url
    assert_not_equal "<script>alert(1)</script>", movie.overview
  end

  test "creating a choice reports an unknown TMDB id instead of raising" do
    stub_tmdb_movie(424_242, body: { "status_message" => "Not found" }, status: 404)
    sign_in users(:alice)

    assert_no_difference(["Choice.count", "Movie.count"]) do
      post event_choices_path(@empty_event), params: { tmdb_id: 424_242 }
    end

    assert_redirected_to event_path(@empty_event)
    assert_equal "Ce film est introuvable sur TMDB.", flash[:alert]
  end

  test "creating a choice reports a TMDB outage instead of raising" do
    stub_request(:get, %r{themoviedb}).to_timeout
    sign_in users(:alice)

    assert_no_difference(["Choice.count", "Movie.count"]) do
      post event_choices_path(@empty_event), params: { tmdb_id: 550 }
    end

    assert_redirected_to event_path(@empty_event)
    assert_equal "TMDB est momentanément indisponible.", flash[:alert]
  end

  test "creating a choice refuses to add the same movie to an event twice" do
    sign_in users(:alice)

    assert_no_difference("Choice.count") do
      post event_choices_path(@event), params: { tmdb_id: movies(:matrix).tmdb_id }
    end

    assert_redirected_to event_path(@event)
    assert_match "déjà dans la liste", flash[:alert]
  end
end
