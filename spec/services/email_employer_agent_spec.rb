require 'rails_helper'

RSpec.describe EmailEmployerAgent do
  let(:defect) { create(:property_defect) }

  describe '#call' do
    it 'emails the employer agent' do
      employer_agent_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward)
        .with('employer_agent', defect.scheme.employer_agent_email_address, defect.id)
        .and_return(employer_agent_message_delivery)
      expect(employer_agent_message_delivery).to receive(:deliver_later)

      described_class.new(defect: defect).call
    end
  end
end
