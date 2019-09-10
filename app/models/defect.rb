require 'csv'

# rubocop:disable Metrics/ClassLength
class Defect < ApplicationRecord
  attr_accessor :send_contractor_email, :send_employer_agent_email

  validates :title,
            :description,
            :trade,
            :priority,
            :status,
            :target_completion_date,
            presence: true

  validates :contact_email_address, format: { with: URI::MailTo::EMAIL_REGEXP },
                                    allow_blank: true
  validates :contact_phone_number, numericality: true,
                                   length: { minimum: 10, maximum: 15 },
                                   allow_blank: true

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

  scope :open_and_closed, (-> { open.or(closed) })
  scope :open, (-> { where(status: %i[outstanding follow_on end_of_year dispute referral]) })
  scope :closed, (-> { where(status: %i[completed closed raised_in_error rejected]) })

  scope :property_and_communal, (-> { property.or(communal) })
  scope :property, (-> { where(communal: false) })
  scope :communal, (-> { where(communal: true) })

  scope :for_priorities, (->(priority_ids) { where(priority_id: priority_ids) })
  scope :for_properties, (->(property_ids) { where(property_id: property_ids) })
  scope :for_communal_areas, (->(communal_area_ids) { where(communal_area_id: communal_area_ids) })
  scope :for_properties_or_communal_areas, lambda { |property_ids, communal_area_ids|
    for_properties(property_ids).or(for_communal_areas(communal_area_ids))
  }
  scope :for_scheme, (lambda { |scheme_ids|
    property_ids = Property.joins(:scheme).where(schemes: { id: scheme_ids }).pluck(:id)
    communal_area_ids = CommunalArea.joins(:scheme).where(schemes: { id: scheme_ids }).pluck(:id)
    for_properties_or_communal_areas(property_ids, communal_area_ids)
  })

  scope :for_trades, (->(trade_names) { where(trade: trade_names) })

  belongs_to :property, optional: true
  belongs_to :communal_area, optional: true
  belongs_to :priority
  has_many :comments, dependent: :destroy

  def scheme
    return communal_area&.scheme if communal_area
    return property&.scheme if property
  end

  include PublicActivity::Model
  tracked \
    owner: ->(controller, _) { controller.current_user if controller },
    params: { changes: ->(_, model) { model.tracked_changes } }

  before_update :remember_changes_for_activity
  attr_reader :tracked_changes

  def remember_changes_for_activity
    selected_changes = changes.slice(:flagged, :status)
    @tracked_changes = selected_changes unless selected_changes.empty?
  end

  PLUMBING_TRADES = [
    'Plumbing',
    'Drainage',
    'Water Temperature/Supply',
  ].freeze

  ELECTRICAL_TRADES = [
    'Electrical',
    'Electrical/Mechanical',
    'Connectivity',
    'Lighting',
    'Boiler work',
    'MVHR',
    'Fan/Ventilation',
    'Fire Safety',
    'Lifts',
    'Heating',
    'Intercoms/Entry Phones',
    'Filters',
  ].freeze

  CARPENTRY_TRADES = [
    'Carpentry',
    'Carpentry/Doors',
    'Door work',
    'Window Work',
    'Metal work',
  ].freeze

  COSMETIC_TRADES = [
    'Cosmetic',
    'Damp',
    'Floor work',
    'Mastic',
    'Decoration',
    'Tile work',
    'Plastering',
    'Blinds',
    'Brickwork',
    'Roof work',
  ].freeze

  TRADES = (
    PLUMBING_TRADES +
    ELECTRICAL_TRADES +
    CARPENTRY_TRADES +
    COSMETIC_TRADES
  ).sort.uniq.freeze

  CATEGORIES = {
    'Plumbing' => PLUMBING_TRADES,
    'Electrical/Mechanical' => ELECTRICAL_TRADES,
    'Carpentry/Doors' => CARPENTRY_TRADES,
    'Cosmetic' => COSMETIC_TRADES,
  }.freeze

  def self.send_chain(methods)
    methods.inject(self) { |s, method| s.send(*method) }
  end

  def self.by_reference_number(number)
    find_by(sequence_number: number.to_i)
  end

  def reference_number
    return nil if new_record?

    reload if sequence_number.blank?
    ReferenceNumber.new(sequence_number).to_s
  end

  def set_target_completion_date(date = nil)
    if date
      self.target_completion_date = date
    elsif priority
      self.target_completion_date = Date.current + priority.days.days
    end
  end

  def set_actual_completion_date(date)
    self.actual_completion_date = date
  end

  def self.format_status(status)
    status.tr('_', ' ').capitalize
  end

  def status
    Defect.format_status(super)
  end

  def contact_phone_number=(value)
    super(value&.tr(' ', ''))
  end

  def token
    MessageVerifier.verifier.generate(
      id,
      purpose: :accept_defect_ownership,
      expires_in: 3.months
    )
  end

  def self.to_csv(defects:)
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      defects.each do |defect|
        csv << DefectPresenter.new(defect).to_row
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
      category
      priority_name
      priority_duration
      target_completion_date
      actual_completion_date
      estate
      scheme
      property_address
      communal_area_name
      communal_area_location
      description
      access_information
    ]
  end
end
# rubocop:enable Metrics/ClassLength
