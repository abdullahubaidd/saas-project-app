class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @organizations = current_user.organizations.includes(:projects, :users).order(:name)
    @recent_projects = current_user.projects.includes(:organization).order(updated_at: :desc).limit(5)
    @pending_invitations = current_user.sent_invitations.pending.includes(:organization).order(created_at: :desc).limit(5)
  end
end
