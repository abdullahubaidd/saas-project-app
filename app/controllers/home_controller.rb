class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  skip_before_action :set_current_organization, only: [:index]
  skip_before_action :ensure_organization_access, only: [:index]
  
  def index
    if user_signed_in?
      # Redirect authenticated users to dashboard or organization selection
      if current_user.organizations.any?
        redirect_to dashboard_path and return
      else
        redirect_to new_organization_path, notice: 'Welcome! Please create your first organization.' and return
      end
    end
    
    # Landing page for non-authenticated users
    @organizations = Organization.limit(5) # Show some public organizations
  end
end
