class Staff::DashboardController < Staff::BaseController
  def index
    @schemes = Scheme.all
  end
end
