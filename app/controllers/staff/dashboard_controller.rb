class Staff::DashboardController < Staff::BaseController
  def index
    @estates = Estate.all
    @search = Search.new
    @defect_filter = DefectFilter.new
  end
end
