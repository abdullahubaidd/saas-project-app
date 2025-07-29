class User < ApplicationRecord
  acts_as_tenant :tenant
  
  belongs_to :tenant
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  validates :email, uniqueness: { scope: :tenant_id }
end
