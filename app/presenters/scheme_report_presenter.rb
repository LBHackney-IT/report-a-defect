class SchemeReportPresenter < ReportPresenter
  attr_accessor :scheme
  delegate :name, to: :scheme

  def initialize(scheme:,
                 report_form: ReportForm.new(from_date: scheme.created_at, to_date: Date.current))
    self.scheme = scheme
    self.report_form = report_form
  end

  def defects
    @defects ||= Defect.for_scheme([scheme.id])
                       .where(
                         'created_at >= ? and created_at <= ?',
                         report_form.from_date.beginning_of_day, report_form.to_date.end_of_day
                       )
  end

  def defects_by_priority(priority:)
    defects.for_priorities([priority.id])
  end
end
