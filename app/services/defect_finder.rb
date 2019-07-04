class DefectFinder
  attr_accessor :filter

  def initialize(filter: {})
    self.filter = filter
  end

  def call
    defects.includes(:property,
                     :communal_area,
                     :priority,
                     property: :scheme,
                     communal_area: :scheme)
           .order(:target_completion_date)
           .map { |defect| DefectPresenter.new(defect) }
  end

  def defects
    Defect.send(filter.scope)
  end
end
