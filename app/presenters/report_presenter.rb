module ReportPresenter
  attr_accessor :schemes, :report_form

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

  def priority_percentage(priority:)
    percentage_for(
      number: Float(defects_completed_on_time(priority: priority).count),
      total: Float(defects_by_priority(priority: priority).count)
    )
  end

  def due_defects_by_priority(priority:)
    defects = defects_by_priority(priority: priority)
    defects.open.where('target_completion_date >= ?', Date.current)
  end

  def overdue_defects_by_priority(priority:)
    (
      defects_closed_late(priority: priority) +
      defects_still_open_and_overdue(priority: priority) +
      closed_defects_with_no_completion_date(priority: priority)
    ).uniq
  end

  def defects_completed_on_time(priority:)
    closed_defects(priority: priority).select do |closed_defect|
      next if closed_defect.actual_completion_date.nil?

      closed_defect.actual_completion_date <= closed_defect.target_completion_date
    end
  end

  private

  def percentage_for(number:, total:)
    return '0.0%' if number.zero? || total.zero?
    percentage = (number / total) * 100
    "#{percentage.round(2)}%"
  end

  def closed_defects(priority:)
    defects_by_priority(priority: priority).closed
  end

  def defects_closed_late(priority:)
    defects = defects_by_priority(priority: priority)
    defects.closed.where('target_completion_date < actual_completion_date')
  end

  # This is a catch-all, as some defects may not have a completion date due to
  # the hacky way in which they are marked as closed - we have no way of telling whether
  # they were completed on time, so this should make any data inconsistencies obvious
  # for the team to fix
  def closed_defects_with_no_completion_date(priority:)
    defects = defects_by_priority(priority: priority)
    defects.closed.where(actual_completion_date: nil)
  end

  def defects_still_open_and_overdue(priority:)
    defects = defects_by_priority(priority: priority)
    defects.open.where('target_completion_date < ?', Date.current)
  end
end
