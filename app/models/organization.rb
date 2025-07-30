class Organization < ApplicationRecord
  # Organization IS the tenant in our system
  belongs_to :owner, class_name: 'User', optional: true
  
  has_many :organization_memberships, dependent: :destroy
  has_many :members, through: :organization_memberships, source: :user
  has_many :projects, dependent: :destroy
  has_many :invitations, dependent: :destroy
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  # Remove subdomain validation since we're not using subdomains
  
  before_validation :generate_slug
  after_update :add_owner_as_admin, if: :saved_change_to_owner_id?
  
  private
  
  def generate_slug
    if name.present? && slug.blank?
      self.slug = name.parameterize
    end
  end
  
  def add_owner_as_admin
    if owner.present? && !organization_memberships.exists?(user: owner)
      organization_memberships.create!(user: owner, role: 'admin')
    end
  end
end
