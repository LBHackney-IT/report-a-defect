class Staff::DefectsController < Staff::BaseController
  def index
    @defects = Defect.all
                     .includes(:property, :communal_area, :priority)
                     .map { |defect| DefectPresenter.new(defect) }
  end
end
