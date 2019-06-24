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

  def defect_path_for(defect:)
    if defect.communal?
      block_defect_path(defect.block, defect.id)
    else
      property_defect_path(defect.property, defect.id)
    end
  end

  def defect_type_for(defect:)
    defect.communal? ? 'Block' : 'Property'
  end
end
