class Staff::DashboardController < Staff::BaseController
  def index
    @estates = Estate.all
    @search = Search.new
  end
end
