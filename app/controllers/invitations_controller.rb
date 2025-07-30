class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:accept]
  before_action :set_organization, except: [:accept]
  before_action :set_invitation, only: [:show, :destroy, :resend]

  def index
    authorize_organization_admin!
    @invitations = @organization.invitations.includes(:invited_by).order(created_at: :desc)
    @pending_invitations = @invitations.pending.select(&:invitation_valid?)
    @expired_invitations = @invitations.expired
  end

  def show
    authorize_organization_admin!
  end

  def new
    authorize_organization_admin!
    @invitation = @organization.invitations.build
  end

  def create
    authorize_organization_admin!
    @invitation = @organization.invitations.build(invitation_params)
    @invitation.invited_by = current_user

    if @invitation.save
      # In development, log the invitation URL for testing
      Rails.logger.info "=== INVITATION CREATED ==="
      Rails.logger.info "Email: #{@invitation.email}"
      Rails.logger.info "Role: #{@invitation.role}"
      Rails.logger.info "Invitation URL: #{@invitation.invitation_url}"
      Rails.logger.info "========================="
      
      redirect_to organization_invitations_path(@organization), 
                  notice: "Invitation sent to #{@invitation.email}. Check server logs for invitation link."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_organization_admin!
    @invitation.destroy
    redirect_to organization_invitations_path(@organization), notice: 'Invitation was cancelled.'
  end

  def resend
    authorize_organization_admin!
    
    if @invitation.valid?
      # Extend expiration and regenerate token
      @invitation.update!(
        expires_at: 7.days.from_now,
        token: SecureRandom.urlsafe_base64(32)
      )
      
      Rails.logger.info "=== INVITATION RESENT ==="
      Rails.logger.info "Email: #{@invitation.email}"
      Rails.logger.info "New Invitation URL: #{@invitation.invitation_url}"
      Rails.logger.info "=========================="
      
      redirect_to organization_invitations_path(@organization), 
                  notice: "Invitation resent to #{@invitation.email}. Check server logs for new invitation link."
    else
      redirect_to organization_invitations_path(@organization), 
                  alert: 'Cannot resend expired invitation.'
    end
  end

  def accept
    # Find invitation without tenant context since we don't have a user yet
    @invitation = ActsAsTenant.without_tenant do
      Invitation.unscoped.find_by!(token: params[:token])
    end
    
    if @invitation.expired?
      render :expired and return
    end
    
    if @invitation.accepted?
      redirect_to root_path, notice: 'This invitation has already been accepted.'
      return
    end

    # Check if user with this email already exists
    existing_user = User.find_by(email: @invitation.email)
    
    if existing_user
      # User exists, check if they're already in the organization
      if existing_user.member_of?(@invitation.organization)
        redirect_to root_path, notice: 'You are already a member of this organization.'
        return
      end
      
      # Set tenant context for existing operations
      ActsAsTenant.with_tenant(@invitation.organization) do
        if @invitation.accept!(existing_user)
          # Sign in the user and set organization context
          sign_in(existing_user)
          session[:current_organization_id] = @invitation.organization.id
          redirect_to @invitation.organization, notice: 'Welcome to the organization!'
        else
          redirect_to root_path, alert: 'Could not join the organization.'
        end
      end
    else
      # Auto-create new user account with tenant context
      ActsAsTenant.with_tenant(@invitation.organization) do
        new_user = @invitation.auto_accept_and_create_user!
        
        if new_user
          # Sign in the new user and set organization context
          sign_in(new_user)
          session[:current_organization_id] = @invitation.organization.id
          redirect_to @invitation.organization, 
                      notice: 'Welcome! Your account has been created and you have been added to the organization. Check server logs for your login credentials.'
        else
          redirect_to root_path, alert: 'Could not create your account. Please contact the organization administrator.'
        end
      end
    end
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
    # Update session to reflect the current organization context
    session[:current_organization_id] = @organization.id
    @current_organization = @organization
    ActsAsTenant.current_tenant = @organization
  end

  def set_invitation
    @invitation = @organization.invitations.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end

  def authorize_organization_admin!
    unless current_user.admin_of?(@organization)
      redirect_to @organization, alert: 'Access denied. Organization admin privileges required.'
    end
  end
end
