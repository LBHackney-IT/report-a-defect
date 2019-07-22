class DefectEventPresenter
  def initialize(event)
    @event = event
  end

  def description # rubocop:disable Metrics/CyclomaticComplexity
    case @event.key
    when 'defect.create' then
      description_for_create
    when 'defect.update' then
      description_for_update
    when 'defect.forwarded_to_contractor' then
      descrition_for_forwarded_to_contractor
    when 'defect.forwarded_to_employer_agent' then
      description_for_forwarded_to_employer_agent
    when 'defect.accepted' then
      description_for_accepted
    when 'defect.notification.contact.sent_to_contractor' then
      description_for_sent_on_to_contact
    when 'defect.notification.contact.accepted_by_contractor' then
      description_for_accepted_by_to_contact
    when 'defect.notification.contact.completed' then
      description_for_completed
    else
      @event.key
    end
  end

  private

  def description_for_create
    if @event.owner
      I18n.t('events.defect.created', name: @event.owner.name)
    else
      @event.key
    end
  end

  def description_for_update
    if params[:changes]&.key?(:status)
      old, new = params[:changes][:status].map { |status| Defect.format_status(status) }
      I18n.t('events.defect.status_changed', name: @event.owner.name, old: old, new: new)
    else
      I18n.t('events.defect.updated', name: @event.owner.name)
    end
  end

  def descrition_for_forwarded_to_contractor
    I18n.t(
      'events.defect.forwarded_to_contractor',
      email: @event.trackable.scheme.contractor_email_address
    )
  end

  def description_for_forwarded_to_employer_agent
    I18n.t(
      'events.defect.forwarded_to_employer_agent',
      email: @event.trackable.scheme.employer_agent_email_address
    )
  end

  def description_for_accepted
    I18n.t(
      'events.defect.accepted',
      email: @event.trackable.scheme.contractor_email_address
    )
  end

  def description_for_sent_on_to_contact
    I18n.t(
      'events.defect.notification.contact.sent_to_contractor',
      phone_number: @event.trackable.contact_phone_number
    )
  end

  def description_for_accepted_by_to_contact
    I18n.t(
      'events.defect.notification.contact.accepted_by_contractor',
      phone_number: @event.trackable.contact_phone_number
    )
  end

  def description_for_completed
    I18n.t(
      'events.defect.notification.contact.completed',
      phone_number: @event.trackable.contact_phone_number
    )
  end

  def params
    @event.parameters
  end
end
