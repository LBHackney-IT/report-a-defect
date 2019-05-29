class Staff::DashboardController < Staff::BaseController
  def index
    @estates = Estate.all
    @property_search = PropertySearch.new
  end
end
