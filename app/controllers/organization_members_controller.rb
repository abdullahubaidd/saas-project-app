class OrganizationMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_member, only: [:show, :update, :destroy]

  def index
    @members = @organization.members.includes(:organization_memberships).order(:first_name, :last_name)
    @admins = @members.joins(:organization_memberships)
                     .where(organization_memberships: { role: 'admin' })
    @regular_members = @members.joins(:organization_memberships)
                              .where(organization_memberships: { role: 'member' })
  end

  def show
    @member_projects = @member.projects.where(organization: @organization).includes(:project_assignments)
  end

  def update
    authorize_organization_admin!
    
    membership = @organization.organization_memberships.find_by(user: @member)
    
    if membership.update(membership_params)
      redirect_to organization_organization_members_path(@organization), 
                  notice: "#{@member.full_name}'s role was updated."
    else
      redirect_to organization_organization_members_path(@organization), 
                  alert: 'Could not update member role.'
    end
  end

  def destroy
    authorize_organization_admin!
    
    if @member == @organization.owner
      redirect_to organization_organization_members_path(@organization), 
                  alert: 'Cannot remove the organization owner.'
      return
    end
    
    membership = @organization.organization_memberships.find_by(user: @member)
    membership.destroy
    
    redirect_to organization_organization_members_path(@organization), 
                notice: "#{@member.full_name} was removed from the organization."
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
    # Update session to reflect the current organization context
    session[:current_organization_id] = @organization.id
    @current_organization = @organization
    ActsAsTenant.current_tenant = @organization
  end

  def set_member
    @member = @organization.members.find(params[:id])
  end

  def membership_params
    params.require(:organization_membership).permit(:role)
  end

  def authorize_organization_admin!
    unless current_user.admin_of?(@organization)
      redirect_to @organization, alert: 'Access denied. Organization admin privileges required.'
    end
  end
end
