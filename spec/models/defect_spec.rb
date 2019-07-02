require 'rails_helper'

RSpec.describe Defect, type: :model do
  it { should belong_to(:property) }
  it { should have_many(:comments) }

  it_behaves_like 'a trackable resource', resource: described_class, factory_name: :property_defect

  it 'validates presence of required fields' do
    defect = described_class.new
    expect(defect.valid?).to be_falsey

    errors = defect.errors.full_messages

    expect(errors).to include("Title can't be blank")
    expect(errors).to include("Description can't be blank")
    expect(errors).to include("Trade can't be blank")
    expect(errors).to include("Priority can't be blank")
    expect(errors).to include("Target completion date can't be blank")
  end

  describe 'validates that contact phone number looks like one' do
    it 'returns false when it is not a number' do
      defect = build(:defect, contact_phone_number: 'abc')
      expect(defect.valid?).to be_falsey
    end

    context 'when a value includes spaces' do
      it 'returns true' do
        defect = build(:defect, contact_phone_number: '1234 567 8901')
        expect(defect.valid?).to be_truthy
      end
    end

    it 'returns false when a number is too short' do
      defect = build(:defect, contact_phone_number: '123')
      expect(defect.valid?).to be_falsey
    end

    it 'returns false when a number is too long' do
      defect = build(:defect, contact_phone_number: '12345678901234567890')
      expect(defect.valid?).to be_falsey
    end
  end

  describe 'validates that contact email address looks like one' do
    it 'returns true with a valid email address' do
      defect = build(:defect, contact_email_address: 'email@example.com')
      expect(defect.valid?).to be_truthy
    end

    it 'returns false with an invalid email address' do
      defect = build(:defect, contact_email_address: 'not a real email')
      expect(defect.valid?).to be_falsey
    end
  end

  describe '#status' do
    it 'returns the capitalized status' do
      defect = build(:defect, status: 'outstanding')
      expect(defect.status).to eq('Outstanding')
    end

    it 'returns the status without underscores' do
      defect = build(:defect, status: 'follow_on')
      expect(defect.status).to eq('Follow on')
    end
  end

  describe '#set_completion_date' do
    it 'sets the completion date to the number of priority days in the future' do
      travel_to Time.zone.parse('2019-05-23')

      previous_priority = create(:priority, days: 2)
      new_priority = create(:priority, days: 3)

      defect = create(:property_defect, priority: previous_priority)
      defect.reload.priority = new_priority

      defect.set_completion_date

      expect(defect.target_completion_date).to eq(Date.new(2019, 5, 26))

      travel_back
    end
  end

  describe '#token' do
    it 'generates a secret token from the ID' do
      defect = create(:property_defect)

      verifier_double = instance_double(ActiveSupport::MessageVerifier)
      expect(ActiveSupport::MessageVerifier).to receive(:new).and_return(verifier_double)
      expect(verifier_double).to receive(:generate)
        .with(defect.id, purpose: :accept_defect_ownership, expires_in: 3.months)

      defect.token
    end
  end

  describe '#scheme' do
    context 'when the defect has a property' do
      it 'returns the property scheme' do
        defect = create(:property_defect)
        expect(defect.scheme).to eq(defect.property.scheme)
      end
    end

    context 'when the defect has a communal_area' do
      it 'returns the communal_area scheme' do
        defect = create(:communal_defect)
        expect(defect.scheme).to eq(defect.communal_area.scheme)
      end
    end
  end

  describe '#accepted_on' do
    before(:each) do
      travel_to Time.zone.parse('2019-05-23')
    end

    after(:each) do
      travel_back
    end

    context 'when the defect has been accepted' do
      it 'returns the time of acceptance' do
        defect = create(:property_defect)
        PublicActivity::Activity.create(trackable: defect, key: 'defect.accepted')
        expect(defect.accepted_on).to eq('23rd May 2019, 00:00')
      end
    end

    context 'when the defect has NOT been accepted' do
      it 'returns an explanation' do
        defect = create(:property_defect)
        expect(defect.accepted_on).to eq(I18n.t('page_content.defect.show.not_accepted_yet'))
      end
    end
  end

  describe '.to_csv' do
    let(:property) { create(:property, address: '1 Hackney Street') }
    let(:priority) { create(:priority, name: 'P1', days: 1) }
    let!(:property_defect) do
      create(:property_defect,
             property: property,
             priority: priority,
             reference_number: '123ABC',
             title: 'a short title',
             status: :outstanding,
             trade: 'Electrical',
             target_completion_date: Date.new(2020, 10, 1),
             description: 'a long description',
             access_information: 'The key is under the garden pot',
             created_at: Time.utc(2018, 10, 1, 12, 13, 55))
    end

    let(:communal_area) { create(:communal_area, name: 'Pine Creek', location: '1-100 Hackney Street') }
    let!(:communal_defect) do
      create(:communal_defect,
             communal_area: communal_area,
             priority: priority,
             reference_number: '456ABC',
             title: 'a shorter title',
             status: :outstanding,
             trade: 'Electrical',
             target_completion_date: Date.new(2019, 10, 1),
             description: 'a longer description',
             access_information: 'The communal door will be unlocked',
             created_at: Time.utc(2017, 10, 1, 12, 13, 55))
    end

    it 'returns a CSV of all defects ordered by created_at' do
      # The ordering of the contents of this fixture implicitly tests that ordering by created_at
      expected_csv = File.read('spec/fixtures/download_defects.csv')
      generated_csv = Defect.to_csv

      expect(generated_csv).to eq(expected_csv)
    end
  end

  describe '.csv_headers' do
    it 'returns all defects' do
      expect(described_class.csv_headers).to eq(
        %w[
          reference_number
          created_at
          title
          type
          status
          trade
          priority_name
          priority_duration
          target_completion_date
          property_address
          communal_area_name
          communal_area_location
          description
          access_information
        ]
      )
    end
  end

  describe '.to_row' do
    context 'when the defect is for a property' do
      it 'returns an array of values as they should appear in a CSV row' do
        defect = create(:property_defect)
        result = defect.to_row
        expect(result).to eq(
          [
            defect.reference_number,
            defect.created_at.to_s,
            defect.title,
            'Property',
            defect.status,
            defect.trade,
            defect.priority.name,
            defect.priority.days,
            defect.target_completion_date,
            defect.property.address,
            nil,
            nil,
            defect.description,
            defect.access_information,
          ]
        )
      end
    end

    context 'when the defect is for a communal area' do
      it 'returns an array of values as they should appear in a CSV row' do
        defect = create(:communal_defect)
        result = defect.to_row
        expect(result).to eq(
          [
            defect.reference_number,
            defect.created_at.to_s,
            defect.title,
            'Communal',
            defect.status,
            defect.trade,
            defect.priority.name,
            defect.priority.days,
            defect.target_completion_date,
            nil,
            defect.communal_area.name,
            defect.communal_area.location,
            defect.description,
            defect.access_information,
          ]
        )
      end
    end
  end
end
