class DefectFilter
  attr_accessor :statuses

  def initialize(statuses: [])
    self.statuses = statuses
  end

  def scope
    return :all if open? && closed?
    return :open if open?
    return :closed if closed?
    :none
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
