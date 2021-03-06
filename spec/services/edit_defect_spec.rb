require 'rails_helper'

RSpec.describe EditDefect do
  let(:defect) { create(:property_defect) }
  let(:defect_params) do
    build(:property_defect)
      .attributes
      .except!('id')
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

    context 'when the actual completion date is present' do
      let(:service) do
        described_class.new(
          defect: defect,
          defect_params: defect_params,
          options: { actual_completion_date: { day: 25, month: 12, year: 2020 } }
        )
      end

      it 'updates the actual_completion_date' do
        result = service.call
        expect(result.actual_completion_date).to eq(Date.new(2020, 12, 25))
      end
    end

    context 'when the status was already completed' do
      let(:defect) { create(:property_defect, status: :completed) }
      let(:defect_params) do
        { description: 'foo' }
      end

      it 'does not enqueues a job to notify the contact again' do
        expect(NotifyDefectCompletedJob)
          .not_to receive(:perform_later)
          .with(defect.id)

        service.call
      end
    end

    context 'when the created on date is set' do
      let(:service) do
        described_class.new(
          defect: defect,
          defect_params: defect_params,
          options: { created_at: { day: 25, month: 12, year: 2018 } }
        )
      end

      it 'updates the created_at date' do
        result = service.call
        expect(result.created_at).to eq(Date.new(2018, 12, 25))
      end
    end
  end
end
