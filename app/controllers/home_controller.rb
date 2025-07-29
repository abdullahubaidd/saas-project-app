class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    if ActsAsTenant.current_tenant
      # User is on a tenant subdomain
      @tenant = ActsAsTenant.current_tenant
    else
      # User is on the main domain - show landing page or redirect
      @tenants = Tenant.all
    end
  end
end
