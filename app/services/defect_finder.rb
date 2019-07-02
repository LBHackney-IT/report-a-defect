class DefectFinder
  def call
    Defect.open
          .includes(:property, :communal_area, :priority)
          .order(:target_completion_date)
          .map { |defect| DefectPresenter.new(defect) }
  end
end
