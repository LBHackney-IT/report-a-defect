require 'rails_helper'

RSpec.describe DefectFinder do
  describe '#call' do
    let(:service) do
      described_class.new
    end

    it 'returns an array of DefectPresenters for all Defects' do
      defect_one = create(:property_defect)

      result = service.call

      expect(result).to be_a(Array)
      expect(result.first).to eq(defect_one)
    end
    end
  end
end
