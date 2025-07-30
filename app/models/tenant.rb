class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :organizations, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :invitations, dependent: :destroy
  
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }
  
  before_validation :downcase_subdomain
  
  private
  
  def downcase_subdomain
    self.subdomain = subdomain.downcase if subdomain.present?
  end
end
