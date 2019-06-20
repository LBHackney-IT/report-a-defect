class Staff::SearchesController < Staff::BaseController
  def index
    @search_results = Search.new(query: query)
  end

  private

  def query
    params.permit(:query)[:query]
  end
end
