class CommunalArea < ApplicationRecord
  belongs_to :scheme, dependent: :destroy
  has_many :defects, dependent: :restrict_with_error

  validates :name,
            :location,
            presence: true

  include PgSearch::Model
  pg_search_scope :search_by_name, against: %i[name]

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
