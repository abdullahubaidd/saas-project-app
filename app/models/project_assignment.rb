class ProjectAssignment < ApplicationRecord
  # Remove acts_as_tenant since projects already belong to organizations
  
  belongs_to :user
  belongs_to :project
  
  validates :role, presence: true, inclusion: { in: %w[admin member viewer] }
  validates :user_id, uniqueness: { scope: :project_id }
  
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }
  scope :viewers, -> { where(role: 'viewer') }
  
  def admin?
    role == 'admin'
  end
  
  def member?
    role == 'member'
  end
  
  def viewer?
    role == 'viewer'
  end
end
