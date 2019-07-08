class DefectFinder
  attr_accessor :order, :filter

  def initialize(order: :created_at, filter: NullDefectFilter.new)
    self.order = order
    self.filter = filter
  end

  def call
    defects.includes(:property,
                     :communal_area,
                     :priority,
                     property: :scheme,
                     communal_area: :scheme)
           .order(order)
  end

  def defects
    Defect.send_chain(filter.scopes)
  end
end
