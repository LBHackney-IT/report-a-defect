require 'rails_helper'

RSpec.describe Search do
  describe '#properties' do
    it 'returns only properties with a matching street name' do
      interested_property = create(:property, address: '1 Hackney Street')
      uninterested_property = create(:property, address: '1 London Road')

      result = described_class.new(query: 'Hackney').properties

      expect(result).to include(interested_property)
      expect(result).not_to include(uninterested_property)
    end

    it 'returns only properties with a matching street number' do
      interested_property = create(:property, address: '1 Hackney Street')
      uninterested_property = create(:property, address: '2 Hackney Street')

      result = described_class.new(query: '1').properties

      expect(result).to include(interested_property)
      expect(result).not_to include(uninterested_property)
    end
  end
end
