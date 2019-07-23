class SchemeReportPresenter
  delegate :name, to: :scheme

  attr_accessor :scheme, :report_form

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

  def date_range
    "From #{report_form.from_date} to #{report_form.to_date}"
  end

  def defects_by_status(text:)
    defects.where(status: text)
  end

  def defects_by_category(category:)
    trade_names = Defect::CATEGORIES[category]
    defects.for_trades(trade_names)
  end

  def category_percentage(category:)
    percentage_for(
      number: Float(defects_by_category(category: category).count),
      total: Float(defects.count)
    )
  end

  def defects_by_priority(priority:)
    defects.for_priorities([priority.id])
  end

  def priority_percentage(priority:)
    percentage_for(
      number: Float(defects_by_priority(priority: priority).count),
      total: Float(defects.count)
    )
  end

  def due_defects_by_priority(priority:)
    defects = defects_by_priority(priority: priority)
    defects.where('target_completion_date >= ?', Date.current)
  end

  def overdue_defects_by_priority(priority:)
    defects = defects_by_priority(priority: priority)
    defects.where('target_completion_date < ?', Date.current)
  end

  def defects_completed_on_time(priority:)
    completed_defects(priority: priority).select do |completed_defect|
      updates_before_target_completion = completed_defect.activities.where(
        [
          'key = ? and created_at < ?',
          'defect.update',
          completed_defect.target_completion_date,
        ]
      )

      # TODO: Query parameter JSON at database level rather than in Ruby
      true if updates_before_target_completion.detect do |updated_event|
        updated_event.parameters[:changes][:status]&.last == 'completed'
      end
    end
  end

  private

  def percentage_for(number:, total:)
    return '0.0%' if number.zero? || total.zero?
    percentage = (number / total) * 100
    "#{percentage.round(2)}%"
  end

  def completed_defects(priority:)
    defects_by_priority(priority: priority).completed
  end
end
