require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup { @admin = users(:admin) }

  def build_invitation(**attrs)
    Invitation.new({ created_by: @admin }.merge(attrs))
  end

  test "a token is generated on create" do
    invitation = build_invitation
    invitation.save!

    assert invitation.token.present?
    assert_operator invitation.token.length, :>=, 24
  end

  test "tokens are unique across invitations" do
    a = build_invitation
    a.save!
    duplicate = build_invitation(token: a.token)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:token], "n'est pas disponible"
  end

  test "a fresh invitation is usable" do
    invitation = build_invitation
    invitation.save!

    assert invitation.usable?
    assert_nil invitation.unusable_reason
  end

  test "a revoked invitation is not usable" do
    invitation = build_invitation
    invitation.save!
    invitation.revoke!

    assert_not invitation.usable?
    assert_equal "révoquée", invitation.unusable_reason
  end

  test "an expired invitation is not usable" do
    invitation = build_invitation(expires_at: 1.hour.ago)
    invitation.save!

    assert_not invitation.usable?
    assert_equal "expirée", invitation.unusable_reason
  end

  test "an invitation is not usable once max_uses is reached" do
    invitation = build_invitation(max_uses: 1)
    invitation.save!
    invitation.consume!

    assert_not invitation.usable?
    assert_equal "épuisée", invitation.unusable_reason
  end

  test "consume! increments the counter" do
    invitation = build_invitation(max_uses: 3)
    invitation.save!

    assert_difference -> { invitation.reload.uses_count }, 1 do
      invitation.consume!
    end
  end

  test "consume! refuses to go past max_uses" do
    invitation = build_invitation(max_uses: 1)
    invitation.save!
    invitation.consume!

    assert_raises(ActiveRecord::RecordInvalid) { invitation.consume! }
    assert_equal 1, invitation.reload.uses_count
  end

  test "an invitation with no max_uses never runs out" do
    invitation = build_invitation
    invitation.save!
    5.times { invitation.consume! }

    assert invitation.usable?
  end
end
