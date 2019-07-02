class DefectFinder
  def call
    Defect.all
          .includes(:property, :communal_area, :priority)
          .map { |defect| DefectPresenter.new(defect) }
  end
end
