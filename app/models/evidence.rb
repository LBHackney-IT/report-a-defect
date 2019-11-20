class Evidence < ApplicationRecord
  belongs_to :defect

  mount_uploader :supporting_file, SupportingFileUploader

  validates :description, :supporting_file, presence: true
end
