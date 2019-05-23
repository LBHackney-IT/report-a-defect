class Scheme < ApplicationRecord
  has_many :priorities, dependent: :destroy
  has_many :properties, dependent: :destroy
  belongs_to :estate, dependent: :destroy

  validates :name, presence: true

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
