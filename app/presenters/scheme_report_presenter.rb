class SchemeReportPresenter
  delegate :name, to: :scheme

  attr_accessor :scheme

  def initialize(scheme:)
    self.scheme = scheme
  end

  def defects
    @defects ||= Defect.for_scheme([scheme.id])
  end
end
