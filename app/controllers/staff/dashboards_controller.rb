class Staff::DashboardsController < Staff::BaseController
  def index
    @schemes = Scheme.all
  end
end
