class BuildDate
  attr_accessor :date

  def initialize(date)
    self.date = date
  end

  def call
    date_parts = date.values_at(:day, :month, :year)
    return unless date_parts.all?(&:present?)

    day, month, year = date_parts.map(&:to_i)
    Date.new(year, month, day)
  end
end
