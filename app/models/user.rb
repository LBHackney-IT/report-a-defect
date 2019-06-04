class User < ApplicationRecord
  has_many :comments, dependent: false

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
