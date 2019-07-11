class DefectFilter
  attr_accessor :statuses,
                :types,
                :schemes

  def initialize(statuses: [], types: [], schemes: [])
    self.statuses = statuses
    self.types = types
    self.schemes = schemes
  end

  def scopes
    scopes = [status_scope, type_scope, scheme_scope].compact
    return [:all] if scopes.empty?
    scopes
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

  def scheme_scope
    return nil if schemes.empty?
    [:for_scheme, schemes]
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
