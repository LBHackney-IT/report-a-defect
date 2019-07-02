require 'rails_helper'

RSpec.describe EditDefect do
  let(:defect) { create(:property_defect) }
  let(:defect_params) do
    build(:property_defect).attributes
  end

  describe '#call' do
    let(:service) do
      described_class.new(defect: defect, defect_params: defect_params)
    end

    it 'returns a defect object' do
      expect(service.call).to be_kind_of(Defect)
    end

    it 'passes the new params to assign_attributes' do
      expect(defect).to receive(:assign_attributes).with(defect_params)
      service.call
    end

    context 'when a new priority is present' do
      let(:new_priority) { create(:priority) }
      let(:service) do
        described_class.new(
          defect: defect,
          defect_params: defect_params,
          options: { priority_id: new_priority.id }
        )
      end

      it 'creates an association to the new_priority' do
        result = service.call
        expect(result.priority).to eq(new_priority)
      end

      it 'updates the target_completion_date' do
        result = service.call
        expect(result.target_completion_date).to eq(Date.current + new_priority.days)
      end
    end
  end
end
