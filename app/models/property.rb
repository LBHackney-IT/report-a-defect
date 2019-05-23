class Property < ApplicationRecord
  belongs_to :scheme, dependent: :destroy

  validates :core_name, :address, :postcode, presence: true

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
