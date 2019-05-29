require 'rails_helper'

RSpec.describe PropertySearch do
  describe '#call' do
    it 'returns only properties with a matching street name' do
      interested_property = create(:property, address: '1 Hackney Street')
      uninterested_property = create(:property, address: '1 London Road')

      result = described_class.new(address: 'Hackney').call

      expect(result).to include(interested_property)
      expect(result).not_to include(uninterested_property)
    end

    it 'returns only properties with a matching street number' do
      interested_property = create(:property, address: '1 Hackney Street')
      uninterested_property = create(:property, address: '2 Hackney Street')

      result = described_class.new(address: '1').call

      expect(result).to include(interested_property)
      expect(result).not_to include(uninterested_property)
    end

    it 'returns only properties with a matching core name' do
      interested_property = create(:property, core_name: 'DZ1')
      uninterested_property = create(:property, core_name: 'DZ2')

      result = described_class.new(address: 'DZ1').call

      expect(result).to include(interested_property)
      expect(result).not_to include(uninterested_property)
    end
  end
end
