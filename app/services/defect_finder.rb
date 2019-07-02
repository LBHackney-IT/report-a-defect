class DefectFinder
  def call
    Defect.all
          .includes(:property, :communal_area, :priority)
          .order(:target_completion_date)
          .map { |defect| DefectPresenter.new(defect) }
  end
end
