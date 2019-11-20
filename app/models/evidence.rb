class Evidence < ApplicationRecord
  belongs_to :defect, dependent: :destroy
  belongs_to :user, dependent: false

  mount_uploader :supporting_file, SupportingFileUploader

  validates :description, :supporting_file, presence: true

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
