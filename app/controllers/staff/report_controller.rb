require 'csv'

class Staff::ReportController < Staff::BaseController
  def index
    filter = DefectFilter.new(statuses: %i[open closed])
    @defects = DefectFinder.new(filter: filter).call

    respond_to do |format|
      format.html
      format.csv { send_data Defect.to_csv(defects: @defects) }
    end
  end

  def show
    @scheme = Scheme.find(scheme_id)
    @presenter = SchemeReportPresenter.new(scheme: @scheme)
  end

  private

  def scheme_id
    params[:id]
  end
end
