class InvitationsController < ApplicationController
  # `show` is the join page: it is the one action an anonymous visitor may reach.
  skip_before_action :authenticate_user!, only: :show
  before_action :require_admin, except: :show

  def index
    @invitations = Invitation.includes(:created_by).recent_first
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(invitation_params.merge(created_by: current_user))

    if @invitation.save
      redirect_to invitations_path, notice: "Lien d'invitation créé."
    else
      @invitations = Invitation.includes(:created_by).recent_first
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    Invitation.find(params[:id]).revoke!
    redirect_to invitations_path, notice: "Invitation révoquée."
  end

  # Landing page for /rejoindre/:token. Holding the invitation in the session is
  # what later authorises RegistrationsController to accept a sign-up.
  def show
    return redirect_to(root_path) if user_signed_in?

    @invitation = Invitation.find_by(token: params[:token])

    if @invitation.nil?
      redirect_to new_user_session_path, alert: "Ce lien d'invitation n'existe pas."
    elsif !@invitation.usable?
      redirect_to new_user_session_path, alert: "Cette invitation est #{@invitation.unusable_reason}."
    else
      session[:invitation_token] = @invitation.token
      redirect_to new_user_registration_path
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:label, :max_uses, :expires_at)
  end
end
