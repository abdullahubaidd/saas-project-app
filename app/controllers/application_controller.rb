class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :authenticate_user!
  before_action :set_current_organization
  before_action :ensure_organization_access
  
  set_current_tenant_through_filter
  
  protected
  
  def set_current_organization
    return unless user_signed_in?
    
    # If user has a specific organization in session, use that
    if session[:current_organization_id] && current_user.organizations.exists?(session[:current_organization_id])
      @current_organization = current_user.organizations.find(session[:current_organization_id])
    else
      # Default to user's primary organization or first available organization
      @current_organization = current_user.organization || current_user.organizations.first
      session[:current_organization_id] = @current_organization&.id
    end
    
    # Set the tenant for acts_as_tenant
    if @current_organization
      ActsAsTenant.current_tenant = @current_organization
    end
  end
  
  def ensure_organization_access
    return unless user_signed_in?
    
    # Skip for organization creation and selection pages
    return if controller_name == 'organizations' && ['new', 'create', 'switch'].include?(action_name)
    return if controller_name == 'home'
    return if controller_name == 'invitations' && action_name == 'accept'
    return if devise_controller?
    
    # For controllers with organization_id in params, they handle their own organization setting
    # We just need to make sure an organization was set by their set_organization method
    if params[:organization_id].present?
      return if @organization.present? || @current_organization.present?
    end
    
    # Redirect to organization selection if no current organization
    unless @current_organization
      redirect_to new_organization_path, alert: 'Please create or select an organization first.'
    end
  end
  
  def switch_organization(organization)
    if current_user.member_of?(organization)
      session[:current_organization_id] = organization.id
      @current_organization = organization
      ActsAsTenant.current_tenant = organization
    end
  end
  
  helper_method :current_organization
  
  def current_organization
    @current_organization
  end
  
  private

  def set_current_tenant
    # Use the organization set by set_current_organization
    ActsAsTenant.current_tenant = @current_organization
  end
end
