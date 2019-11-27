class CombinedReportPresenter < ReportPresenter
  def initialize(schemes: [],
                 report_form: ReportForm.new(from_date: Scheme::REPORT_MONTHS.months.ago,
                                             to_date: Date.current))
    self.schemes = schemes
    self.report_form = report_form
  end

  def defects
    @defects ||= Defect.for_scheme(schemes.pluck(:id))
                       .where(created_at: report_form.date_range)
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

  def priorities_with_defects
    priorities.select { |priority| defects_by_priority(priority: priority).any? }
  end
end
