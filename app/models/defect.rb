require 'csv'

# rubocop:disable Metrics/ClassLength
class Defect < ApplicationRecord
  before_validation :set_completion_date
  validates :title,
            :description,
            :trade,
            :priority,
            :reference_number,
            :status,
            :target_completion_date,
            presence: true

  validates :contact_email_address, format: { with: URI::MailTo::EMAIL_REGEXP },
                                    allow_blank: true
  validates :contact_phone_number, numericality: true,
                                   length: { minimum: 10, maximum: 15 },
                                   allow_blank: true
  attribute :reference_number, :string, default: -> { SecureRandom.hex(3).upcase }

  enum status: %i[
    outstanding
    completed
    closed
    raised_in_error
    follow_on
    end_of_year
    dispute
    referral
    rejected
  ]

  belongs_to :property, optional: true
  belongs_to :communal_area, optional: true
  belongs_to :priority
  has_many :comments, dependent: :destroy

  def scheme
    return communal_area&.scheme if communal_area
    return property&.scheme if property
  end

  include PublicActivity::Model
  tracked owner: ->(controller, _) { controller.current_user if controller }

  TRADES = [
    'Blinds',
    'Boiler work',
    'Brickwork',
    'Carpentry',
    'Connectivity',
    'Cosmetic',
    'Damp',
    'Decoration',
    'Door work',
    'Drainage',
    'Electrical',
    'Fan/Ventilation',
    'Filters',
    'Fire Safety',
    'Floor work',
    'Heating',
    'Intercoms/Entry Phones',
    'Lifts',
    'Lighting',
    'Mastic',
    'Metal work',
    'MVHR',
    'Plastering',
    'Plumbing',
    'Roof work',
    'Tile work',
    'Water Temperature/Supply',
    'Window Work',
    'Cosmetic',
    'Carpentry/Doors',
    'Plumbing',
    'Electrical/Mechanical',
  ].freeze

  def set_completion_date
    return unless priority

    self.target_completion_date = Date.current + priority.days.days
  end

  def status
    super.tr('_', ' ').capitalize
  end

  def contact_phone_number=(value)
    super(value.tr(' ', ''))
  end

  def token
    MessageVerifier.verifier.generate(
      id,
      purpose: :accept_defect_ownership,
      expires_in: 3.months
    )
  end

  def accepted_on
    acceptance_event = activities.find_by(key: 'defect.accepted')
    return I18n.t('page_content.defect.show.not_accepted_yet') unless acceptance_event

    acceptance_event.created_at.to_s
  end

  def self.to_csv
    all_defects = all.includes(:priority, :property, :communal_area)

    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      all_defects.order(:created_at).each do |defect|
        csv << defect.to_row
      end
    end
  end

  def self.csv_headers
    %w[
      reference_number
      created_at
      title
      type
      status
      trade
      priority_name
      priority_duration
      target_completion_date
      property_address
      communal_area_name
      communal_area_location
      description
      access_information
    ]
  end

  def to_row
    [
      reference_number,
      created_at.to_s,
      title,
      communal? ? 'Communal' : 'Property',
      status,
      trade,
      priority.name,
      priority.days,
      target_completion_date,
      property&.address,
      communal_area&.name,
      communal_area&.location,
      description,
      access_information,
    ]
  end
end
# rubocop:enable Metrics/ClassLength
