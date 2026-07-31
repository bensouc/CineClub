require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "fixture event is valid" do
    assert events(:movie_night).valid?
  end

  test "is invalid without a name" do
    event = events(:movie_night)
    event.name = nil
    assert_not event.valid?
    assert_includes event.errors[:name], "can't be blank"
  end

  test "is invalid without a date" do
    event = events(:movie_night)
    event.date = nil
    assert_not event.valid?
    assert_includes event.errors[:date], "can't be blank"
  end

  test "movies are reachable through choices" do
    assert_equal [movies(:inception), movies(:matrix)].sort_by(&:id),
                 events(:movie_night).movies.sort_by(&:id)
  end

  test "exequo? is false when there are fewer than two choices" do
    assert_not events(:empty_night).exequo?
  end

  test "exequo? is true when the top two choices share the same ranking" do
    # Both fixture choices in movie_night have ranking 1.
    assert events(:movie_night).exequo?
  end

  test "exequo? is false when the top choice outranks the others" do
    event = events(:movie_night)
    choices(:matrix_choice).update!(ranking: 5)
    assert_not event.reload.exequo?
  end

  test "destroying an event destroys its choices and their votes" do
    event = events(:movie_night)
    assert_difference("Choice.count", -event.choices.count) do
      assert_difference("Vote.count", -Vote.where(choice: event.choices).count) do
        event.destroy
      end
    end
  end
end
