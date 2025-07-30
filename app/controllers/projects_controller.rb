class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project, only: [:show, :edit, :update, :destroy, :archive, :unarchive]
  before_action :authorize_project_access!, only: [:show, :edit, :update, :destroy, :archive, :unarchive]

  def index
    # Organization admins can see all projects, regular users only see projects they're assigned to
    if current_user.admin_of?(@organization)
      @projects = @organization.projects.active.includes(:users)
      @archived_projects = @organization.projects.archived.includes(:users)
    else
      @projects = current_user.projects.where(organization: @organization).active.includes(:users)
      @archived_projects = current_user.projects.where(organization: @organization).archived.includes(:users)
    end
  end

  def show
    @members = @project.users.includes(:project_assignments)
  end

  def new
    authorize_organization_admin!
    @project = @organization.projects.build
  end

  def create
    authorize_organization_admin!
    @project = @organization.projects.build(project_params)
    @project.created_by = current_user

    if @project.save
      redirect_to [@organization, @project], notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_project_admin!
  end

  def update
    authorize_project_admin!
    
    if @project.update(project_params)
      redirect_to [@organization, @project], notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_project_admin!
    @project.destroy
    redirect_to organization_projects_url(@organization), notice: 'Project was successfully deleted.'
  end

  def archive
    authorize_project_admin!
    @project.archive!
    redirect_to [@organization, @project], notice: 'Project was archived.'
  end

  def unarchive
    authorize_project_admin!
    @project.unarchive!
    redirect_to [@organization, @project], notice: 'Project was unarchived.'
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
    @project = @organization.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def authorize_organization_admin!
    unless current_user.admin_of?(@organization)
      redirect_to @organization, alert: 'Access denied. Organization admin privileges required.'
    end
  end

  def authorize_project_admin!
    project_assignment = current_user.project_assignments.find_by(project: @project)
    unless current_user.admin_of?(@organization) || project_assignment&.admin?
      redirect_to [@organization, @project], alert: 'Access denied. Project admin privileges required.'
    end
  end

  def authorize_project_access!
    unless current_user.member_of_project?(@project)
      redirect_to @organization, alert: 'Access denied. You are not a member of this project.'
    end
  end
end
