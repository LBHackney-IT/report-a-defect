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

    it 'emails a copy of the defect to the contractor and employer agent' do
      scheme = create(:scheme,
                      contractor_email_address: 'contractor@email.com',
                      employer_agent_email_address: 'employeragent@email.com')
      property = create(:property, scheme: scheme)
      defect = create(:property_defect, property: property)

      described_class.new(defect: defect).call

      first_delivery = ActionMailer::Base.deliveries[0]
      expect(first_delivery.to).to eq([defect.property.scheme.contractor_email_address])
      expect(first_delivery.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))

      second_delivery = ActionMailer::Base.deliveries[1]
      expect(second_delivery.to).to eq([defect.property.scheme.employer_agent_email_address])
      expect(second_delivery.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))
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
