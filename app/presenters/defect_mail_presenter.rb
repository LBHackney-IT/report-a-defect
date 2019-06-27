class DefectMailPresenter < SimpleDelegator
  include DatetimeHelper

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
    format_time(created_at)
  end
end
