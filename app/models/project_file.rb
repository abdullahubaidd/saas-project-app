class ProjectFile < ApplicationRecord
  acts_as_tenant(:organization)
  
  belongs_to :project
  belongs_to :uploaded_by, class_name: 'User'
  
  has_one_attached :file
  
  validates :file, presence: true
  validates :description, length: { maximum: 500 }
  
  def filename
    file.attached? ? file.filename.to_s : 'Unknown'
  end
  
  def file_size
    file.attached? ? ActiveSupport::NumberHelper.number_to_human_size(file.byte_size) : '0 B'
  end
  
  def file_type
    file.attached? ? file.content_type : 'application/octet-stream'
  end
end
