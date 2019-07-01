require 'csv'

class Staff::ReportController < Staff::BaseController
  def index
    @defects = Defect.all
    respond_to do |format|
      format.html
      format.csv { send_data @defects.to_csv }
    end
  end
end
