class Staff::SearchesController < Staff::BaseController
  def index
    @properties = Search.new(query: query).properties
  end

  private

  def query
    params.permit(:query)[:query]
  end
end
