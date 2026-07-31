require "test_helper"

# Sign-up is closed unless the visitor arrived through an invitation link.
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup { @invitation = Invitation.create!(created_by: users(:admin)) }

  def signup_params(email = "nouveau@example.com")
    { user: { email: email, password: "password123", password_confirmation: "password123" } }
  end

  test "the sign-up form is closed without an invitation" do
    get new_user_registration_path

    assert_redirected_to new_user_session_path
    assert_equal "L'inscription se fait uniquement sur invitation.", flash[:alert]
  end

  test "posting a sign-up without an invitation creates nothing" do
    assert_no_difference("User.count") do
      post user_registration_path, params: signup_params
    end

    assert_redirected_to new_user_session_path
  end

  test "the sign-in page offers no way to create an account" do
    get new_user_session_path

    assert_response :success
    assert_not_includes response.body, new_user_registration_path
  end

  test "following an invitation link opens the form and lets you sign up" do
    get join_path(@invitation.token)
    get new_user_registration_path
    assert_response :success

    assert_difference("User.count", 1) do
      post user_registration_path, params: signup_params
    end

    assert_equal 1, @invitation.reload.uses_count
  end

  test "a new member is never an admin" do
    get join_path(@invitation.token)
    post user_registration_path, params: signup_params

    assert_not User.find_by(email: "nouveau@example.com").admin?
  end

  test "the invitation is only consumed when the account is actually created" do
    get join_path(@invitation.token)

    # Same email as an existing fixture, so the record is invalid.
    assert_no_difference("User.count") do
      post user_registration_path, params: signup_params(users(:alice).email)
    end

    assert_equal 0, @invitation.reload.uses_count
  end

  test "a single-use invitation cannot be reused after sign-up" do
    @invitation.update!(max_uses: 1)

    get join_path(@invitation.token)
    post user_registration_path, params: signup_params
    delete destroy_user_session_path

    get join_path(@invitation.token)
    assert_equal "Cette invitation est épuisée.", flash[:alert]

    assert_no_difference("User.count") do
      post user_registration_path, params: signup_params("autre@example.com")
    end
  end
end
