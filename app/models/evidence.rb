class Evidence < ApplicationRecord
  belongs_to :defect

  validates :description, presence: true

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
