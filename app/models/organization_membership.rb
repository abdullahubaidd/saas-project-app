class OrganizationMembership < ApplicationRecord
  # Remove acts_as_tenant since we're managing organizations globally now
  
  belongs_to :user
  belongs_to :organization
  
  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :user_id, uniqueness: { scope: :organization_id }
  
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }
  
  def admin?
    role == 'admin'
  end
  
  def member?
    role == 'member'
  end
end
