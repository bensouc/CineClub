module Users
  # Sign-up is invitation-only: the club is private. Devise's registerable module
  # stays enabled so members can still edit or delete their own account, but
  # new/create are gated behind a valid invitation held in the session.
  class RegistrationsController < Devise::RegistrationsController
    before_action :require_invitation, only: [:new, :create]

    def create
      super do |user|
        # Only burn the invitation once the account actually exists.
        if user.persisted?
          current_invitation.consume!
          session.delete(:invitation_token)
        end
      end
    end

    private

    def current_invitation
      @current_invitation ||= Invitation.find_by(token: session[:invitation_token])
    end

    def require_invitation
      return if current_invitation&.usable?

      session.delete(:invitation_token)
      redirect_to new_user_session_path,
                  alert: "L'inscription se fait uniquement sur invitation."
    end
  end
end
