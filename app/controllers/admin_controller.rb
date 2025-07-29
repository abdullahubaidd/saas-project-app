class AdminController < ApplicationController
  skip_before_action :set_current_tenant
  skip_before_action :authenticate_user!
  
  def index
    @tenants = Tenant.all.includes(:users)
  end
  
  def create_tenant
    @tenant = Tenant.new(tenant_params)
    
    if @tenant.save
      redirect_to admin_index_path, notice: "Tenant '#{@tenant.name}' created successfully!"
    else
      redirect_to admin_index_path, alert: "Error creating tenant: #{@tenant.errors.full_messages.join(', ')}"
    end
  end
  
  private
  
  def tenant_params
    params.require(:tenant).permit(:name, :subdomain)
  end
end
