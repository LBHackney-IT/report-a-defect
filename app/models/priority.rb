class Priority < ApplicationRecord
  belongs_to :scheme, dependent: :destroy
end
