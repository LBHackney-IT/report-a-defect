class Priority < ApplicationRecord
  validates :name, :duration, presence: true
  belongs_to :scheme, dependent: :destroy
end
