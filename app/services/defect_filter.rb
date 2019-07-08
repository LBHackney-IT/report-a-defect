class DefectFilter
  attr_accessor :statuses

  def initialize(statuses: [])
    self.statuses = statuses
  end

  def scopes
    [status_scope].compact
  end

  private

  def status_scope
    return :open_and_closed if open? && closed?
    return :open if open?
    return :closed if closed?
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
end
