class Estate < ApplicationRecord
  validates :name, presence: true
  has_many :schemes, dependent: :destroy

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
