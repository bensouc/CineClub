require "test_helper"

class ChoiceTest < ActiveSupport::TestCase
  test "fixture choice is valid" do
    assert choices(:inception_choice).valid?
  end

  test "is invalid without a ranking" do
    choice = choices(:inception_choice)
    choice.ranking = nil
    assert_not choice.valid?
    assert_includes choice.errors[:ranking], "can't be blank"
  end

  test "the same movie cannot appear twice in one event" do
    duplicate = Choice.new(
      user: users(:bob),
      movie: movies(:inception), # already chosen in movie_night
      event: events(:movie_night),
      ranking: 0
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:movie], "Ce film est déjà dans la liste"
  end

  test "the same movie can appear in a different event" do
    choice = Choice.new(
      user: users(:bob),
      movie: movies(:inception), # chosen in movie_night, but not in empty_night
      event: events(:empty_night),
      ranking: 0
    )
    assert choice.valid?
  end

  test "destroying a choice destroys its votes" do
    choice = choices(:inception_choice)
    assert_difference("Vote.count", -choice.votes.count) do
      choice.destroy
    end
  end
end
