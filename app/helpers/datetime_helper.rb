module DatetimeHelper
  class FormatDateError < RuntimeError; end

  def format_date(date, format = :default)
    return 'No date given' if date.nil?

    date.to_s(format).lstrip
  end

  def format_time(time)
    time.in_time_zone.strftime('%H:%M%P %-d %B %Y')
  end

  def format_time_in_sentence(time)
    time.in_time_zone.strftime('at %H:%M%P on %-d %B %Y')
  end
end
