require 'rails_helper'

RSpec.describe SaveDefect do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe '.initialize' do
    it 'accepts and stores the defect' do
      defect = create(:property_defect)

      result = described_class.new(defect: defect)

      expect(result.defect).to eq(defect)
    end
  end

  describe '#call' do
    let(:defect) { create(:property_defect) }

    it 'saves the record' do
      expect(defect).to receive(:save)
      described_class.new(defect: defect).call
    end

    it 'sends the email asynchronously by default' do
      email_contractor_double = double(EmailContractor)
      expect(EmailContractor).to receive(:new).with(defect: defect).and_return(email_contractor_double)
      expect(email_contractor_double).to receive(:call)

      email_contractor_double = double(EmailEmployerAgent)
      expect(EmailEmployerAgent).to receive(:new).with(defect: defect).and_return(email_contractor_double)
      expect(email_contractor_double).to receive(:call)

      described_class.new(defect: defect).call
    end

    context 'when send_email_to_contractor is false' do
      it 'does not send the contractor email' do
        expect_any_instance_of(EmailContractor).not_to receive(:call)
        described_class.new(defect: defect, send_email_to_contractor: false, send_email_to_employer_agent: false).call
      end
    end

    context 'when send_email_to_employer_agent is false' do
      it 'does not send the employer agent email' do
        expect_any_instance_of(EmailEmployerAgent).not_to receive(:call)
        described_class.new(defect: defect, send_email_to_contractor: false, send_email_to_employer_agent: false).call
      end
    end
  end
end

RSpec.describe SavePropertyDefect do
  describe '#call' do
    let(:defect) { create(:property_defect) }

    it 'leaves communal as false' do
      described_class.new(defect: defect).call
      expect(defect.communal).to eq(false)
    end
  end
end

RSpec.describe SaveCommunalDefect do
  describe '#call' do
    let(:defect) { create(:communal_defect) }

    it 'sets communal to true' do
      described_class.new(defect: defect).call
      expect(defect.communal).to eq(true)
    end
  end
end
