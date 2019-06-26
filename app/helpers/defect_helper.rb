module DefectHelper
  def priority_form_label(priority:)
    "#{priority.name} - #{pluralize(priority.days, 'day')} from now"
  end

  def status_form_label(option_array:)
    option_array.first.capitalize.tr('_', ' ')
  end

  def view_path_for(parent:, defect:)
    return property_defect_path(parent, defect) if parent.is_a?(Property)
    return communal_area_defect_path(parent, defect) if parent.is_a?(CommunalArea)
  end

  def defect_path_for(defect:)
    if defect.communal?
      communal_area_defect_path(defect.communal_area, defect.id)
    else
      property_defect_path(defect.property, defect.id)
    end
  end

  def defect_type_for(defect:)
    defect.communal? ? 'Communal Area' : 'Property'
  end

  def event_description_for(event:)
    case event.key
    when 'defect.create' then
      if event.owner
        I18n.t('events.defect.created', name: event.owner.name)
      else
        event.key
      end
    when 'defect.forwarded_to_contractor' then
      I18n.t(
        'events.defect.forwarded_to_contractor',
        email: event.trackable.scheme.contractor_email_address
      )
    when 'defect.forwarded_to_employer_agent' then
      I18n.t(
        'events.defect.forwarded_to_employer_agent',
        email: event.trackable.scheme.employer_agent_email_address
      )
    when 'defect.accepted' then
      I18n.t(
        'events.defect.accepted',
        email: event.trackable.scheme.contractor_email_address
      )
    else
      event.key
    end
  end
end
