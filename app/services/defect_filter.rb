class DefectFilter
  attr_accessor :statuses,
                :types,
                :schemes,
                :escalations

  def initialize(statuses: [], types: [], schemes: [], escalations: [])
    self.statuses = statuses
    self.types = types
    self.schemes = schemes
    self.escalations = escalations
  end

  def scopes
    scopes = [status_scope, type_scope, scheme_scope, escalation_scope].compact
    return [:all] if scopes.empty?
    scopes
  end

  private

  def status_scope
    return :open_and_closed if open? && closed?
    return :open if open?
    :closed if closed?
  end

  def type_scope
    return :property_and_communal if property? && communal?
    return :property if property?
    :communal if communal?
  end

  def scheme_scope
    return nil if schemes.empty?
    [:for_scheme, schemes]
  end

  def escalation_scope
    if manually_escalated?
      escalated_permutations
    elsif due_soon? && overdue?
      :overdue_and_due_soon
    elsif overdue?
      :overdue
    elsif due_soon?
      :due_soon
    end
  end

  def escalated_permutations
    return if overdue? && due_soon?

    if overdue?
      :flagged_and_overdue
    elsif due_soon?
      :flagged_and_due_soon
    else
      :flagged
    end
  end

  def none?
    statuses.empty?
  end

  def open?
    statuses.include?(:open)
  end

  def closed?
    statuses.include?(:closed)
  end

  def property?
    types.include?(:property)
  end

  def communal?
    types.include?(:communal)
  end

  def manually_escalated?
    escalations.include?(:manually_escalated)
  end

  def overdue?
    escalations.include?(:overdue)
  end

  def due_soon?
    escalations.include?(:due_soon)
  end
end
