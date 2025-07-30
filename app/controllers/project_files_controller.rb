class ProjectFilesController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :authorize_project_access!
  before_action :set_project_file, only: [:show, :destroy]
  
  def index
    @project_files = @project.project_files.order(created_at: :desc)
  end
  
  def new
    @project_file = @project.project_files.build
  end
  
  def create
    @project_file = @project.project_files.build(project_file_params)
    @project_file.uploaded_by = current_user
    
    if @project_file.save
      redirect_to organization_project_path(@organization, @project), 
                  notice: 'File was successfully uploaded.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    redirect_to @project_file.file if @project_file.file.attached?
  end
  
  def destroy
    @project_file.destroy
    redirect_to organization_project_path(@organization, @project), 
                notice: 'File was successfully deleted.'
  end
  
  private
  
  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
    # Set this as the current organization for the session
    session[:current_organization_id] = @organization.id
    @current_organization = @organization
    ActsAsTenant.current_tenant = @organization
  end
  
  def set_project
    @project = @organization.projects.find(params[:project_id])
  end
  
  def set_project_file
    @project_file = @project.project_files.find(params[:id])
  end

  def authorize_project_access!
    unless current_user.member_of_project?(@project)
      redirect_to @organization, alert: 'Access denied. You are not a member of this project.'
    end
  end

  def project_file_params
    params.require(:project_file).permit(:file, :description)
  end
end
