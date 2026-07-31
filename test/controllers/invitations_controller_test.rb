require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @invitation = Invitation.create!(created_by: @admin, label: "Groupe WhatsApp")
  end

  # --- admin management -----------------------------------------------------

  test "the invitation list is admin-only" do
    get invitations_path
    assert_redirected_to new_user_session_path

    sign_in users(:alice)
    get invitations_path
    assert_redirected_to events_path
    assert_equal "Réservé aux administrateurs.", flash[:alert]
  end

  test "an admin sees the list and the share link" do
    sign_in @admin
    get invitations_path

    assert_response :success
    assert_includes response.body, @invitation.token
  end

  test "an admin creates an invitation" do
    sign_in @admin

    assert_difference("Invitation.count", 1) do
      post invitations_path, params: { invitation: { label: "Les copains", max_uses: 5 } }
    end

    invitation = Invitation.recent_first.first
    assert_equal "Les copains", invitation.label
    assert_equal 5, invitation.max_uses
    assert_equal @admin, invitation.created_by
  end

  test "a non-admin cannot create or revoke" do
    sign_in users(:alice)

    assert_no_difference("Invitation.count") do
      post invitations_path, params: { invitation: { label: "Pirate" } }
    end

    delete invitation_path(@invitation)
    assert_not @invitation.reload.revoked?
  end

  test "an admin revokes an invitation" do
    sign_in @admin
    delete invitation_path(@invitation)

    assert_redirected_to invitations_path
    assert @invitation.reload.revoked?
  end

  # --- joining --------------------------------------------------------------

  test "a valid link sends an anonymous visitor to the sign-up form" do
    get join_path(@invitation.token)
    assert_redirected_to new_user_registration_path

    follow_redirect!
    assert_response :success
  end

  test "an unknown token is refused" do
    get join_path("nope")

    assert_redirected_to new_user_session_path
    assert_equal "Ce lien d'invitation n'existe pas.", flash[:alert]
  end

  test "a revoked link is refused" do
    @invitation.revoke!
    get join_path(@invitation.token)

    assert_redirected_to new_user_session_path
    assert_equal "Cette invitation est révoquée.", flash[:alert]
  end

  test "an exhausted link is refused" do
    @invitation.update!(max_uses: 1)
    @invitation.consume!

    get join_path(@invitation.token)
    assert_equal "Cette invitation est épuisée.", flash[:alert]
  end
end
