class Project < ApplicationRecord
  acts_as_tenant :organization
  
  belongs_to :organization
  belongs_to :created_by, class_name: 'User'
  
  has_many :project_assignments, dependent: :destroy
  has_many :users, through: :project_assignments
  has_many :project_files, dependent: :destroy
  
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organization_id },
            format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }
  
  before_validation :generate_slug
  after_create :add_creator_as_admin
  
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  
  def archive!
    update!(archived: true)
  end
  
  def unarchive!
    update!(archived: false)
  end
  
  private
  
  def generate_slug
    if name.present? && slug.blank?
      self.slug = name.parameterize
    end
  end
  
  def add_creator_as_admin
    project_assignments.create!(user: created_by, role: 'admin')
  end
end
