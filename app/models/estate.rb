class Estate < ApplicationRecord
  validates :name, presence: true
  has_many :schemes, dependent: :destroy
end
