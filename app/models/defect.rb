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
    follow_on
    end_of_year_defect
    dispute
    referral
    rejected
  ]

  belongs_to :property, optional: true
  belongs_to :block, optional: true
  belongs_to :priority
  has_many :comments, dependent: :destroy

  def scheme
    return block&.scheme if block
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

    self.target_completion_date = Time .zone.now + priority.days.days
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
end
