class PropertySearch
  attr_accessor :address

  def initialize(address: nil)
    self.address = address
  end

  def call
    Property.search_by_address(address)
  end
end
