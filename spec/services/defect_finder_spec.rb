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

    it 'sorts the list by target_completion_date' do
      defect_two = create(:property_defect, status: :outstanding, target_completion_date: 1.day.from_now)
      defect_one = create(:property_defect, status: :outstanding, target_completion_date: 2.days.from_now)
      defect_five = create(:property_defect, status: :outstanding, target_completion_date: 2.days.ago)
      defect_four = create(:property_defect, status: :outstanding, target_completion_date: 1.day.ago)
      defect_three = create(:property_defect, status: :outstanding, target_completion_date: 0.days.from_now)

      result = service.call

      expect(result[0]).to eq(defect_five)
      expect(result[1]).to eq(defect_four)
      expect(result[2]).to eq(defect_three)
      expect(result[3]).to eq(defect_two)
      expect(result[4]).to eq(defect_one)
    end
  end
end
