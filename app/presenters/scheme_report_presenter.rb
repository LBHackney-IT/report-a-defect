class SchemeReportPresenter
  delegate :name, to: :scheme

  attr_accessor :scheme

  def initialize(scheme:)
    self.scheme = scheme
  end

  def defects
    @defects ||= Defect.for_scheme([scheme.id])
  end

  def date_range
    "From #{scheme.created_at} to #{Time.current}"
  end

  def defects_by_status(text:)
    defects.send(text)
  end
end
