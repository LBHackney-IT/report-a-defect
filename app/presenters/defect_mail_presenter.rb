class DefectMailPresenter < SimpleDelegator
  include DatetimeHelper

  delegate :contractor_name, to: :scheme
  delegate :contractor_email_address, to: :scheme
  delegate :name, to: :priority, prefix: :priority

  def reporting_officer
    'Hackney New Build team'
  end

  def address
    property.present? ? property.address : access_information
  end

  def location
    property.present? ? 'Property' : 'Communal'
  end

  def created_time
    format_time(created_at)
  end
end
