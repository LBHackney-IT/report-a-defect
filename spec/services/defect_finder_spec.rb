require 'rails_helper'

RSpec.describe DefectFinder do
  describe '#call' do
    let(:service) do
      described_class.new
    end

    it 'returns an array of DefectPresenters for open Defects' do
      defect_one = create(:property_defect, status: :outstanding)

      result = service.call

      expect(result).to be_a(Array)
      expect(result.first).to eq(defect_one)
    end

    it 'does not return closed or completed defects' do
      outstanding_defect = create(:property_defect, status: :outstanding)
      follow_on_defect = create(:property_defect, status: :follow_on)
      end_of_year_defect = create(:property_defect, status: :end_of_year)
      dispute_defect = create(:property_defect, status: :dispute)
      referral_defect = create(:property_defect, status: :referral)

      closed_defect = create(:property_defect, status: :closed)
      completed_defect = create(:property_defect, status: :completed)
      raised_in_error_defect = create(:property_defect, status: :raised_in_error)
      rejected_defect = create(:property_defect, status: :rejected)

      result = service.call

      expect(result).to include(outstanding_defect)
      expect(result).to include(follow_on_defect)
      expect(result).to include(end_of_year_defect)
      expect(result).to include(dispute_defect)
      expect(result).to include(referral_defect)

      expect(result).not_to include(closed_defect)
      expect(result).not_to include(completed_defect)
      expect(result).not_to include(raised_in_error_defect)
      expect(result).not_to include(rejected_defect)
    end
    end
  end
end
