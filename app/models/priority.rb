class Priority < ApplicationRecord
  validates :name, :days, presence: true
  validates :days, numericality: { only_integer: true }
  belongs_to :scheme, dependent: :destroy
end
