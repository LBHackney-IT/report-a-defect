class Search
  attr_accessor :query

  def initialize(query: nil)
    self.query = query
  end

  def properties
    @properties ||= Property.search_by_address(query)
  end

  def communal_areas
    @communal_areas ||= CommunalArea.search_by_name(query)
  end
end
