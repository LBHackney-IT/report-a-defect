module DefectHelper
  def priority_form_label(priority:)
    "#{priority.name} - #{pluralize(priority.days, 'day')} from now"
  end

  def status_form_label(option_array:)
    option_array.first.capitalize.tr('_', ' ')
  end

  def view_path_for(parent:, defect:)
    return property_defect_path(parent, defect) if parent.is_a?(Property)
    return block_defect_path(parent, defect) if parent.is_a?(Block)
  end
end
