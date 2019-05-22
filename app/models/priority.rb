class Priority < ApplicationRecord
  validates :name, :days, presence: true
  belongs_to :scheme, dependent: :destroy
end
