class Staff::DefectsController < Staff::BaseController
  def index
    @defects = DefectFinder.new.call
  end
end
