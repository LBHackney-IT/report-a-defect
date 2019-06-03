class Priority < ApplicationRecord
  belongs_to :scheme, dependent: :destroy
  has_many :defects, dependent: :restrict_with_error

  validates :name, :days, presence: true
  validates :days, numericality: { only_integer: true }

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }

  def form_label
    "#{name} - target completion: #{days.days.from_now.to_s(:date)}"
  end
end
