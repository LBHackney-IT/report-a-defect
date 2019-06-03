class Property < ApplicationRecord
  belongs_to :scheme, dependent: :destroy
  has_many :defects, dependent: :restrict_with_error

  validates :core_name,
            :address,
            :postcode,
            :uprn,
            presence: true

  include PgSearch
  pg_search_scope :search_by_address, against: %i[address core_name]

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
