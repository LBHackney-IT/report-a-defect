module DatetimeHelper
  class FormatDateError < RuntimeError; end

  def format_time_in_sentence(time)
    time.in_time_zone.strftime('on %-d %B %Y at %H:%M')
  end
end
