class Staff::DashboardController < Staff::BaseController
  def index
    @estates = Estate.all
  end
end
