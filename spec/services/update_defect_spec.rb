require 'rails_helper'

RSpec.describe UpdateDefect do
  let(:defect) { create(:property_defect) }

  describe '#call' do
    let(:service) do
      described_class.new(defect: defect)
    end

    it 'returns a defect object' do
      expect(service.call).to be_kind_of(Defect)
    end

    it 'does not enqueue a notification' do
      expect(NotifyDefectCompletedJob).not_to receive(:perform_later).with(defect.id)
      service.call
    end

    context 'when the defect has had its status changed to completed' do
      it 'enqueues a notification' do
        defect = create(:property_defect, status: :outstanding)
        defect.status = :completed

        expect(NotifyDefectCompletedJob).to receive(:perform_later).with(defect.id)

        described_class.new(defect: defect).call
      end
    end
  end
end
