class SchemeReportPresenter
  include ReportPresenter
  attr_accessor :scheme

  delegate :name, to: :scheme

  def initialize(scheme:,
                 report_form: ReportForm.new(from_date: scheme.created_at, to_date: Date.current))
    self.scheme = scheme
    self.report_form = report_form
  end

  def defects
    @defects ||= Defect.for_scheme([scheme.id])
                       .where(added_at: report_form.date_range)
  end

  def defects_by_priority(priority:)
    defects.for_priorities([priority.id])
  end
end
