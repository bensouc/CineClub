require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixture user is valid" do
    assert users(:alice).valid?
  end

  test "is invalid without an email" do
    user = users(:alice)
    user.email = nil
    assert_not user.valid?
  end

  test "email must be unique" do
    duplicate = User.new(email: users(:alice).email, password: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "destroying a user destroys their choices and votes" do
    user = users(:alice)
    assert_difference("Choice.count", -user.choices.count) do
      assert_difference("Vote.count", -user.votes.count) do
        user.destroy
      end
    end
  end
end
