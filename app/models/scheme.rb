class Scheme < ApplicationRecord
  has_many :priorities, dependent: :destroy
  has_many :properties, dependent: :destroy
  belongs_to :estate, dependent: :destroy

  validates :name,
            :contractor_name,
            :contractor_email_address,
            presence: true

  validates :contractor_email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :employer_agent_email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }
end
