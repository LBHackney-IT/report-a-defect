class DefectFilter
  attr_accessor :statuses,
                :types

  def initialize(statuses: [], types: [])
    self.statuses = statuses
    self.types = types
  end

  def scopes
    [status_scope, type_scope].compact
  end

  private

  def status_scope
    return :open_and_closed if open? && closed?
    return :open if open?
    return :closed if closed?
  end

  def type_scope
    return :property_and_communal if property? && communal?
    return :property if property?
    return :communal if communal?
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
end
