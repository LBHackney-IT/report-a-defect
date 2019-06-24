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

    it 'sends the email asynchronously' do
      contractor_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward_to_contractor).with(defect.id).and_return(contractor_message_delivery)
      expect(contractor_message_delivery).to receive(:deliver_later)

      employer_agent_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward_to_employer_agent).with(defect.id).and_return(employer_agent_message_delivery)
      expect(employer_agent_message_delivery).to receive(:deliver_later)

      described_class.new(defect: defect).call
    end

    it 'stores sending of an email to the contractor in a custom activity record' do
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

    it 'stores sending of an email to the employer agent in a custom activity record' do
      travel_to Time.zone.parse('2019-05-23')

      described_class.new(defect: defect).call

      result = PublicActivity::Activity.find_by(
        trackable_id: defect.id, trackable_type: Defect.to_s, key: 'defect.forwarded_to_employer_agent'
      )
      expect(result).to be_kind_of(PublicActivity::Activity)
      expect(result.trackable).to be_kind_of(Defect)
      expect(result.created_at).to eq(Time.zone.now)

      travel_back
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
