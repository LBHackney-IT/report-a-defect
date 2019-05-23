class Property < ApplicationRecord
  validates :core_name, :address, :postcode, presence: true
  belongs_to :scheme, dependent: :destroy
end
