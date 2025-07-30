class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [:show, :edit, :update, :destroy, :switch]
  skip_before_action :ensure_organization_access, only: [:new, :create, :switch, :index]

  def index
    @organizations = current_user.organizations.includes(:users, :projects)
  end

  def show
    @projects = @organization.projects.active.includes(:users)
    @members = @organization.members.includes(:organization_memberships)
  end

  def new
    @organization = Organization.new
  end

  def create
    ActsAsTenant.without_tenant do
      @organization = Organization.new(organization_params)
      
      if @organization.save
        # Create the user's organization record and set as primary
        current_user.update!(organization: @organization)
        
        # Set as owner and this will trigger the callback to create admin membership
        @organization.update!(owner: current_user)
        
        # Switch to this organization
        session[:current_organization_id] = @organization.id
        
        redirect_to @organization, notice: 'Organization was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    authorize_admin!
  end

  def update
    authorize_admin!
    
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_admin!
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully deleted.'
  end
  
  def switch
    if current_user.member_of?(@organization)
      session[:current_organization_id] = @organization.id
      redirect_to @organization, notice: "Switched to #{@organization.name}"
    else
      redirect_to organizations_path, alert: 'Access denied to that organization.'
    end
  end

  private

  def set_organization
    if action_name == 'switch'
      @organization = Organization.find(params[:id])
    else
      @organization = current_user.organizations.find(params[:id])
    end
    
    # Update session to reflect the current organization context
    session[:current_organization_id] = @organization.id
    @current_organization = @organization
    ActsAsTenant.current_tenant = @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :description)
  end

  def authorize_admin!
    unless current_user.admin_of?(@organization)
      redirect_to @organization, alert: 'Access denied. Admin privileges required.'
    end
  end
end
