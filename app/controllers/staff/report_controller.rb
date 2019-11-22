require 'csv'

class Staff::ReportController < Staff::BaseController
  def index
    filter = DefectFilter.new(statuses: %i[open closed])
    @defects = DefectFinder.new(filter: filter).call
    @report_form = ReportForm.new(from_date: combined_from_date, to_date: to_date)
    @scheme_list = Scheme.all.order(:name)
    @presenter = CombinedReportPresenter.new(schemes: schemes, report_form: @report_form)

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

  def schemes
    @schemes || Scheme.find(scheme_ids)
  end

  def scheme_ids
    @scheme_ids ||= params[:schemes] || Scheme.within_14_months.pluck(:id)
  end

  def from_date
    date_param(:from_date, scheme.created_at)
  end

  def combined_from_date
    date_param(:from_date, 14.months.ago)
  end

  def to_date
    date_param(:to_date, Date.current)
  end

  def date_param(param_name, default_date)
    form_value = params.fetch(param_name, {})

    day, month, year = %i[day month year].map do |field|
      form_value.fetch(field, default_date.__send__(field)).to_i
    end

    Date.new(year, month, day)
  end
end
