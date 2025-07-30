# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  skip_before_action :set_current_organization, only: [:new, :create]
  skip_before_action :ensure_organization_access, only: [:new, :create]
  
  # POST /resource
  def create
    build_resource(sign_up_params)
    
    resource.save
    yield resource if block_given?
    if resource.persisted?
      # Handle invitation acceptance after successful registration
      handle_invitation_acceptance if session[:invitation_token]
      
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def handle_invitation_acceptance
    invitation = Invitation.find_by(token: session[:invitation_token])
    if invitation&.invitation_valid?
      # Create organization membership for the new user
      OrganizationMembership.create!(
        user: resource,
        organization: invitation.organization,
        role: invitation.role
      )
      
      # Set user's primary organization if they don't have one
      resource.update!(organization: invitation.organization) unless resource.organization
      
      # Accept the invitation
      invitation.update!(status: 'accepted')
      session.delete(:invitation_token)
      flash[:notice] = "Welcome to #{invitation.organization.name}!"
    end
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    if resource.organizations.any?
      resource.organizations.first
    else
      new_organization_path
    end
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
