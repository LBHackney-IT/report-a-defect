class Search
  attr_accessor :query

  def initialize(query: nil)
    self.query = query
  end

  def properties
    Property.search_by_address(query)
  end
end
