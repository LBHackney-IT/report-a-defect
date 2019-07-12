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
    total = Float(defects.count)
    trade_total = Float(defects_by_trade(text: text).count)

    return '0.0%' if total.zero? || trade_total.zero?

    percentage = (trade_total / total) * 100
    "#{percentage}%"
  end
end
