class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :admin?

  private

  # Nil-safe so views can call it on pages that do not require a session.
  def admin?
    current_user&.admin?
  end

  def require_admin
    return if admin?

    redirect_to events_path, alert: "Réservé aux administrateurs."
  end
end
