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
    @report_form = ReportForm.new(from_date: from_date, to_date: to_date)
    @scheme = scheme
    @presenter = SchemeReportPresenter.new(scheme: scheme, report_form: @report_form)
  end

  private

  def scheme
    @scheme ||= Scheme.find(scheme_id)
  end

  def scheme_id
    params[:id]
  end

  def from_date
    Date.new(from_year, from_month, from_day)
  end

  def to_date
    Date.new(to_year, to_month, to_day)
  end

  def from_day
    params.fetch(:from_day, scheme.created_at.day).to_i
  end

  def from_month
    params.fetch(:from_month, scheme.created_at.month).to_i
  end

  def from_year
    params.fetch(:from_year, scheme.created_at.year).to_i
  end

  def to_day
    params.fetch(:to_day, Date.current.day).to_i
  end

  def to_month
    params.fetch(:to_month, Date.current.month).to_i
  end

  def to_year
    params.fetch(:to_year, Date.current.year).to_i
  end
end
