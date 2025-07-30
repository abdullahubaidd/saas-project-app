class Invitation < ApplicationRecord
  acts_as_tenant :organization
  
  belongs_to :organization
  belongs_to :invited_by, class_name: 'User'
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :email, uniqueness: { scope: :organization_id, message: "has already been invited to this organization" }
  
  before_create :generate_token
  before_create :set_expires_at
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :valid, -> { where('expires_at > ?', Time.current) }
  
  def pending?
    status == 'pending'
  end
  
  def accepted?
    status == 'accepted'
  end
  
  def expired?
    expires_at < Time.current
  end
  
  def invitation_valid?
    expires_at > Time.current && pending?
  end
  
  def accept!(user)
    return false if expired? || accepted?
    
    ActiveRecord::Base.transaction do
      organization.organization_memberships.create!(user: user, role: role)
      update!(status: 'accepted')
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def auto_accept_and_create_user!
    return false if expired? || accepted?
    
    # Generate a random password
    password = SecureRandom.alphanumeric(12)
    
    begin
      ActiveRecord::Base.transaction do
        # Create user account (users are global, not tenant-scoped)
        user = ActsAsTenant.without_tenant do
          User.create!(
            email: email,
            password: password,
            password_confirmation: password,
            confirmed_at: Time.current, # Auto-confirm the user
            first_name: email.split('@').first.humanize, # Use email prefix as first name
            last_name: "User" # Default last name
          )
        end
        
        # Add user to organization (this needs tenant context)
        organization.organization_memberships.create!(user: user, role: role)
        
        # Mark invitation as accepted
        update!(status: 'accepted')
        
        # Send welcome email with credentials (in development, just log)
        UserMailer.welcome_email(user, password, organization).deliver_now
        
        user
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to auto-create user from invitation: #{e.message}"
      false
    end
  end
  
  def invitation_url
    Rails.application.routes.url_helpers.accept_invitation_url(
      token: token,
      host: Rails.application.config.default_host || "localhost:3000"
    )
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
  
  def set_expires_at
    self.expires_at = 7.days.from_now
  end
end
