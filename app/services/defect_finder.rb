class DefectFinder
  def call
    Defect.open
          .includes(:property, :communal_area, :priority)
          .map { |defect| DefectPresenter.new(defect) }
  end
end
