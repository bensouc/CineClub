require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "fixture vote is valid" do
    assert votes(:alice_inception).valid?
  end

  test "a user cannot vote twice for the same choice" do
    duplicate = Vote.new(user: users(:alice), choice: choices(:inception_choice))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user], "Tu as déjà voté pour ce film"
  end

  test "a user can vote for a different choice" do
    vote = Vote.new(user: users(:alice), choice: choices(:matrix_choice))
    assert vote.valid?
  end

  test "a different user can vote for the same choice" do
    vote = Vote.new(user: users(:bob), choice: choices(:inception_choice))
    assert vote.valid?
  end
end
