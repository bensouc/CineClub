require "test_helper"

class ChoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:movie_night)
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
end
