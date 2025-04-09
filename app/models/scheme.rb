class Scheme < ApplicationRecord
  REPORT_MONTHS = 14

  has_many :priorities, dependent: :destroy
  has_many :communal_areas, dependent: :destroy
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

  scope :recent, -> { where(start_date: [REPORT_MONTHS.months.ago..Time.zone.now]) }

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }

  def set_start_date(date)
    date = BuildDate.new(date).call
    self.start_date = date if date.present?
  end
end
