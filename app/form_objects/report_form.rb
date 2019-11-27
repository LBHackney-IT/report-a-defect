class ReportForm
  attr_accessor :from_date,
                :to_date

  def initialize(from_date:, to_date:)
    self.from_date = from_date.to_date
    self.to_date = to_date.to_date
  end

  def date_range
    (from_date.beginning_of_day)..(to_date.end_of_day)
  end
end
