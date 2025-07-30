class User < ApplicationRecord
  # Remove acts_as_tenant from User since we'll manage it at controller level
  
  belongs_to :organization, optional: true  # Primary organization for new signups
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :project_assignments, dependent: :destroy
  has_many :projects, through: :project_assignments
  has_many :sent_invitations, class_name: 'Invitation', foreign_key: 'invited_by_id'
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
         
  validates :email, uniqueness: true  # Remove scope since users are global now
  validates :first_name, :last_name, presence: true
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def admin_of?(organization)
    organization_memberships.find_by(organization: organization)&.role == 'admin'
  end
  
  def member_of?(organization)
    organizations.include?(organization)
  end
  
  def member_of_project?(project)
    projects.include?(project) || admin_of?(project.organization)
  end
  
  # Get user's primary organization or first organization
  def primary_organization
    organization || organizations.first
  end
end
