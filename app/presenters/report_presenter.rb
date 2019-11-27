class ReportPresenter
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
    defects.where('target_completion_date >= ?', Date.current)
  end

  def overdue_defects_by_priority(priority:)
    defects = defects_by_priority(priority: priority)
    defects.where('target_completion_date < ?', Date.current)
  end

  def defects_completed_on_time(priority:)
    completed_defects(priority: priority).select do |completed_defect|
      completed_defect_activities = completed_defect.activities.where(key: 'defect.update')
      activities_on_time = completed_defect_activities.select do |activity|
        activity.created_at.to_date <= completed_defect.target_completion_date
      end

      # TODO: Query parameter JSON at database level rather than in Ruby
      true if activities_on_time.detect do |update_activity|
        update_activity.parameters &&
        update_activity.parameters[:changes] &&
        update_activity.parameters[:changes][:status]&.last == 'completed'
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
