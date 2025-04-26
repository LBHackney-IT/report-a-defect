Date::DATE_FORMATS[:default] = '%e %B %Y'
Time::DATE_FORMATS[:default] = lambda { |time|
  "#{time.day.ordinalize} #{time.strftime('%B %Y, %H:%M')}"
}
