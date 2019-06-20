class Block < ApplicationRecord
  belongs_to :scheme, dependent: :destroy
  has_many :defects, dependent: :restrict_with_error

  validates :name,
            presence: true

  include PgSearch
  pg_search_scope :search_by_name, against: %i[name]

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
