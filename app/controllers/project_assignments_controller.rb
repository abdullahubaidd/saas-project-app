class ProjectAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :authorize_organization_admin!
  before_action :set_project_assignment, only: [:destroy]

  def index
    @project_assignments = @project.project_assignments.includes(:user)
    @organization_members = @organization.members.where.not(id: @project.users.ids)
  end

  def new
    @project_assignment = @project.project_assignments.build
    @available_members = @organization.members.where.not(id: @project.users.ids)
  end

  def create
    @project_assignment = @project.project_assignments.build(project_assignment_params)
    @project_assignment.role = 'member' if @project_assignment.role.blank? # Default role
    
    if @project_assignment.save
      redirect_to [@organization, @project], 
                  notice: "#{@project_assignment.user.email} has been added to the project."
    else
      @available_members = @organization.members.where.not(id: @project.users.ids)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    user_email = @project_assignment.user.email
    @project_assignment.destroy
    redirect_to [@organization, @project], 
                notice: "#{user_email} has been removed from the project."
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
    # Update session to reflect the current organization context
    session[:current_organization_id] = @organization.id
    @current_organization = @organization
    ActsAsTenant.current_tenant = @organization
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def set_project_assignment
    @project_assignment = @project.project_assignments.find(params[:id])
  end

  def project_assignment_params
    params.require(:project_assignment).permit(:user_id, :role)
  end

  def authorize_organization_admin!
    unless current_user.admin_of?(@organization)
      redirect_to [@organization, @project], alert: 'Access denied. Organization admin privileges required.'
    end
  end
end
