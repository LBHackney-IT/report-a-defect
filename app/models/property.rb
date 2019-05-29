class Property < ApplicationRecord
  belongs_to :scheme, dependent: :destroy

  validates :core_name, :address, :postcode, presence: true

  include PgSearch
  pg_search_scope :search_by_address, against: %i[address]

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
