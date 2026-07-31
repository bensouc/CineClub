# A shareable link that lets someone create an account. Sign-up is closed
# otherwise: the club is private, and only an admin hands out invitations.
class Invitation < ApplicationRecord
  belongs_to :created_by, class_name: "User"

  validates :token, presence: true, uniqueness: true
  validates :uses_count, numericality: { greater_than_or_equal_to: 0 }
  validates :max_uses, numericality: { greater_than: 0 }, allow_nil: true

  before_validation :generate_token, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  def usable?
    !revoked? && !expired? && !exhausted?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def exhausted?
    max_uses.present? && uses_count >= max_uses
  end

  # Why it cannot be used, for the admin list and the join page.
  def unusable_reason
    return "révoquée" if revoked?
    return "expirée" if expired?
    return "épuisée" if exhausted?

    nil
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  # Counts one accepted sign-up. Atomic so two people opening the same link at
  # once cannot both slip past a max_uses of 1.
  def consume!
    with_lock do
      raise ActiveRecord::RecordInvalid, self unless usable?

      increment!(:uses_count)
    end
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end
end
