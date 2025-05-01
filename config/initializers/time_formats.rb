Date::DATE_FORMATS[:default] = '%e %B %Y'
Time::DATE_FORMATS[:default] = ->(time) { time.strftime("#{time.day.ordinalize} %B %Y, %H:%M") }