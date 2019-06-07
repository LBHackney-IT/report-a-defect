require 'rails_helper'

RSpec.describe SaveDefect do
  describe '.initialize' do
    it 'accepts and stores the defect' do
      defect = create(:defect)

      result = described_class.new(defect: defect)

      expect(result.defect).to eq(defect)
    end
  end

  describe '#call' do
    let(:defect) { create(:defect) }

    it 'saves the record' do
      expect(defect).to receive(:save)
      described_class.new(defect: defect).call
    end

    it 'emails a copy of the defect to the contractor' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward).with(defect.id) { message_delivery }
      expect(message_delivery).to receive(:deliver_now)

      described_class.new(defect: defect).call
    end

    it 'stores sending of an email in a custom activity record' do
      travel_to Time.zone.parse('2019-05-23')

      described_class.new(defect: defect).call

      result = PublicActivity::Activity.find_by(
        trackable_id: defect.id, trackable_type: Defect.to_s, key: 'defect.forwarded_to_contractor'
      )
      expect(result).to be_kind_of(PublicActivity::Activity)
      expect(result.trackable).to be_kind_of(Defect)
      expect(result.created_at).to eq(Time.zone.now)

      travel_back
    end
  end
end
