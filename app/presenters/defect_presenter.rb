class DefectPresenter < SimpleDelegator
  delegate :contractor_name, to: :scheme
  delegate :contractor_email_address, to: :scheme
  delegate :name, to: :priority, prefix: :priority

  def reporting_officer
    'Hackney New Build team'
  end

  def address
    communal? ? communal_area.location : property.address
  end

  def defect_type
    property.present? ? 'Property' : 'Communal'
  end

  def created_time
    created_at.to_s
  end

  def accepted_on
    acceptance_event = activities.find_by(key: 'defect.accepted')
    return I18n.t('page_content.defect.show.not_accepted_yet') unless acceptance_event

    acceptance_event.created_at.to_s
  end

  def target_completion_date
    super.to_s
  end

  def actual_completion_date
    super.to_s
  end

  def category
    return 'Plumbing' if Defect::PLUMBING_TRADES.include?(trade)
    return 'Electrical/Mechanical' if Defect::ELECTRICAL_TRADES.include?(trade)
    return 'Carpentry/Doors' if Defect::CARPENTRY_TRADES.include?(trade)
    return 'Cosmetic' if Defect::COSMETIC_TRADES.include?(trade)
    trade
  end

  # rubocop:disable Metrics/AbcSize
  def to_row
    [
      reference_number,
      created_at.to_s,
      added_at.to_s,
      title,
      defect_type,
      status,
      trade,
      category,
      priority.name,
      priority.days,
      target_completion_date,
      actual_completion_date,
      scheme.estate.name,
      scheme.name,
      property&.address,
      communal_area&.name,
      communal_area&.location,
      description,
      access_information,
    ]
  end
  # rubocop:enable Metrics/AbcSize
end
