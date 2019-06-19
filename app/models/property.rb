class Property < ApplicationRecord
  belongs_to :scheme, dependent: :destroy
  has_many :defects, dependent: :restrict_with_error

  validates :address,
            :postcode,
            :uprn,
            presence: true

  validates :uprn, uniqueness: true

  include PgSearch
  pg_search_scope :search_by_address, against: %i[address]

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
