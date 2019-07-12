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

  def defects_by_trade(text:)
    defects.for_trade(text)
  end

  def trade_percentage(text:)
    percentage_for(
      number: Float(defects_by_trade(text: text).count),
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

  private

  def percentage_for(number:, total:)
    return '0.0%' if number.zero? || total.zero?
    percentage = (number / total) * 100
    "#{percentage}%"
  end
end
