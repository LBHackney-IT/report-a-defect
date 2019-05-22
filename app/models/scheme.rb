class Scheme < ApplicationRecord
  validates :name, presence: true
  has_many :priorities, dependent: :destroy
  belongs_to :estate, dependent: :destroy
end
