class DefectEventPresenter
  def initialize(event)
    @event = event
  end

  def description
    case @event.key
    when 'defect.create' then
      description_for_create
    when 'defect.forwarded_to_contractor' then
      descrition_for_forwarded_to_contractor
    when 'defect.forwarded_to_employer_agent' then
      description_for_forwarded_to_employer_agent
    when 'defect.accepted' then
      description_for_accepted
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

  def params
    @event.parameters
  end
end
