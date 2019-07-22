require 'rails_helper'

RSpec.describe EmailContractor do
  let(:defect) { create(:property_defect) }

  describe '#call' do
    it 'emails the contractor' do
      contractor_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward)
        .with('contractor', defect.scheme.contractor_email_address, defect.id)
        .and_return(contractor_message_delivery)
      expect(contractor_message_delivery).to receive(:deliver_later)

      described_class.new(defect: defect).call
    end

    it 'sends an SMS to the contact phone number' do
      expect(NotifyDefectSentToContractorJob).to receive(:perform_later).with(defect.id)
      described_class.new(defect: defect).call
    end
  end
end
