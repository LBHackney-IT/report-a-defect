class ReportForm
  attr_accessor :from_date,
                :to_date

  def initialize(from_date:, to_date:)
    self.from_date = from_date.to_date
    self.to_date = to_date.to_date
  end

  def from_day
    from_date.day
  end

  def from_month
    from_date.month
  end

  def from_year
    from_date.year
  end

  def to_day
    to_date.day
  end

  def to_month
    to_date.month
  end

  def to_year
    to_date.year
  end
end
