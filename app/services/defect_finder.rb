class DefectFinder
  attr_accessor :filter

  def initialize(filter: NullDefectFilter.new)
    self.filter = filter
  end

  def call
    defects.includes(:property,
                     :communal_area,
                     :priority,
                     property: :scheme,
                     communal_area: :scheme)
           .order(:target_completion_date)
  end

  def defects
    Defect.send(filter.scope)
  end
end
