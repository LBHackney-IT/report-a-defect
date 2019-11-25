class CombinedReportPresenter < ReportPresenter
  def initialize(schemes: [],
                 report_form: ReportForm.new(from_date: 14.months.ago, to_date: Date.current))
    self.schemes = schemes
    self.report_form = report_form
  end

  def defects
    @defects ||= Defect.for_scheme(schemes.pluck(:id))
                       .where(
                         'created_at >= ? and created_at <= ?',
                         report_form.from_date.beginning_of_day, report_form.to_date.end_of_day
                       )
  end

  def defects_by_priority(priority:)
    priorities = Priority.joins(:scheme)
                         .where(schemes: { id: schemes.pluck(:id) })
                         .where(priorities: { name: priority })
    defects.for_priorities(priorities)
  end

  def priorities
    Priority.group(:name).pluck(:name).sort
  end
end
