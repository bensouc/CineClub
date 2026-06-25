require "test_helper"

class EventTest < ActiveSupport::TestCase
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
end
