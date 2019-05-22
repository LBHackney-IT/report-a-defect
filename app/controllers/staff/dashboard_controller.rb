class Staff::DashboardController < Staff::BaseController
  def index
    @schemes = Scheme.all
    @estates = Estate.all
  end
end
