class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :set_current_tenant
  before_action :authenticate_user!
  
  set_current_tenant_through_filter
  
  private

  def set_current_tenant
    # Get tenant from subdomain or default logic
    subdomain = request.subdomain
    
    if subdomain.present? && subdomain != 'www'
      tenant = Tenant.find_by(subdomain: subdomain)
      if tenant
        ActsAsTenant.current_tenant = tenant
      else
        redirect_to root_url(subdomain: nil), alert: 'Tenant not found'
      end
    else
      # Handle main domain - redirect to a default tenant or show landing page
      # For now, we'll allow access without tenant for the home page
      ActsAsTenant.current_tenant = nil if action_name == 'index' && controller_name == 'home'
    end
  end
end
