module DefectHelper
  def priority_form_label(priority:)
    "#{priority.name} - #{pluralize(priority.days, 'day')} from now"
  end

  def status_form_label(option_array:)
    option_array.first.capitalize.tr('_', ' ')
  end
end
