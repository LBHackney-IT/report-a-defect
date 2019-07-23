class Staff::SearchesController < Staff::BaseController
  def index
    number = ReferenceNumber.parse(query)

    if number
      search_by_reference_number(number)
    else
      @search_results = Search.new(query: query)
    end
  end

  private

  def query
    params.permit(:query)[:query]
  end

  def search_by_reference_number(number)
    defect = Defect.by_reference_number(number)

    if defect
      redirect_to helpers.defect_path_for(defect: defect)
    else
      flash[:notice] = I18n.t('page_content.defect.not_found', reference_number: query)
      redirect_to dashboard_path
    end
  end
end
