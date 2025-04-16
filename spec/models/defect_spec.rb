require 'rails_helper'
class TestDefect < Defect
  scope :any_scope, ->(args) { where(id: args) }
end

RSpec.describe Defect, type: :model do
  it { should belong_to(:property).optional }
  it { should belong_to(:communal_area).optional }
  it { should have_many(:comments) }
  it { should have_many(:evidences) }

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

  describe 'added_at' do
    it 'automatically populates added_at' do
      defect = create(:defect)
      the_date = Time.zone.now.to_date.to_s # can't freeze because setting happens in Postgres
      expect(defect.reload.added_at.to_date.to_s).to eq(the_date)
    end
  end

  describe '.for_properties' do
    it 'returns a list of defects for a given property ID' do
      interested_property = create(:property)
      interested_property_defect = create(:property_defect, property: interested_property)
      distracting_property = create(:property)
      distracting_property_defect = create(:property_defect, property: distracting_property)

      result = described_class.for_properties([interested_property.id])

      expect(result).to include(interested_property_defect)
      expect(result).not_to include(distracting_property_defect)
    end
  end

  describe '.for_communal_areas' do
    it 'returns a list of defects for a given communal area ID' do
      interested_communal_area = create(:communal_area)
      interested_communal_defect = create(:communal_defect, communal_area: interested_communal_area)
      distracting_communal_area = create(:communal_area)
      distracting_communal_defect = create(:communal_defect, communal_area: distracting_communal_area)

      result = described_class.for_communal_areas([interested_communal_area.id])

      expect(result).to include(interested_communal_defect)
      expect(result).not_to include(distracting_communal_defect)
    end
  end

  describe '.for_properties_or_communal_areas' do
    it 'returns a list of defects that match either a list of property_ids or communal_area_ids' do
      interested_property = create(:property)
      interested_property_defect = create(:property_defect, property: interested_property)
      distracting_property = create(:property)
      distracting_property_defect = create(:property_defect, property: distracting_property)

      interested_communal_area = create(:communal_area)
      interested_communal_defect = create(:communal_defect, communal_area: interested_communal_area)
      distracting_communal_area = create(:communal_area)
      distracting_communal_defect = create(:communal_defect, communal_area: distracting_communal_area)

      result = described_class.for_properties_or_communal_areas(
        [interested_property.id],
        [interested_communal_area.id]
      )

      expect(result).to include(interested_property_defect)
      expect(result).to include(interested_communal_defect)
      expect(result).not_to include(distracting_property_defect)
      expect(result).not_to include(distracting_communal_defect)
    end
  end

  describe '.for_scheme' do
    it 'returns a list of defects that belong to provided schemes' do
      interested_scheme = create(:scheme)
      interested_property = create(:property, scheme: interested_scheme)
      interested_defect = create(:property_defect, property: interested_property)

      distracting_defect_with_different_scheme = create(:property_defect)

      result = described_class.for_scheme(
        [interested_scheme.id]
      )

      expect(result).to include(interested_defect)
      expect(result).not_to include(distracting_defect_with_different_scheme)
    end
  end

  describe '#reference_number' do
    it 'returns a formatted identifier code' do
      defect = create(:defect, sequence_number: 42)
      expect(defect.reference_number).to eq('NB-000-042')
    end

    it 'uses sequential identifiers' do
      defects = create_list(:defect, 5)
      ids = defects.map { |d| d.reference_number.scan(/\d/).join('').to_i }
      first = ids.first
      expect(ids).to eq((0..4).map { |i| first + i })
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

    it 'records update changes in the activity log' do
      defect = create(:defect, status: 'outstanding')
      defect.status = :follow_on
      defect.save

      event = defect.activities.find_by(key: 'defect.update')
      expect(event.parameters[:changes]).to eq('status' => %w[outstanding follow_on])
    end
  end

  describe '#flagged' do
    it 'records update changes in the activity log' do
      defect = create(:defect, status: 'outstanding', flagged: false)
      defect.flagged = true
      defect.save

      event = defect.activities.find_by(key: 'defect.update')
      expect(event.parameters[:changes]).to eq('flagged' => [false, true])
    end
  end

  describe '#set_target_completion_date' do
    it 'sets the target completion date to the number of priority days in the future' do
      travel_to Time.zone.parse('2019-05-23')

      previous_priority = create(:priority, days: 2)
      new_priority = create(:priority, days: 3)

      defect = create(:property_defect, priority: previous_priority)
      defect.reload.priority = new_priority

      defect.set_target_completion_date

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

  describe '.to_csv' do
    let(:estate) { create(:estate, name: 'estate') }
    let(:scheme) { create(:scheme, name: 'scheme', estate: estate) }
    let(:property) { create(:property, address: '1 Hackney Street', scheme: scheme) }
    let(:priority) { create(:priority, name: 'P1', days: 1) }
    let!(:property_defect) do
      create(:property_defect,
             property: property,
             priority: priority,
             sequence_number: 1,
             title: 'a short title',
             status: :outstanding,
             trade: 'Electrical',
             target_completion_date: Date.new(2020, 10, 1),
             actual_completion_date: Date.new(2020, 9, 30),
             description: 'a long description',
             access_information: 'The key is under the garden pot',
             created_at: Time.utc(2018, 10, 1, 12, 13, 55),
             added_at: Time.utc(2018, 10, 1, 11, 13, 55),
             flagged: true)
    end

    let(:communal_area) { create(:communal_area, name: 'Pine Creek', location: '1-100 Hackney Street', scheme: scheme) }
    let!(:communal_defect) do
      create(:communal_defect,
             communal_area: communal_area,
             priority: priority,
             sequence_number: 2,
             title: 'a shorter title',
             status: :outstanding,
             trade: 'Electrical',
             target_completion_date: Date.new(2019, 10, 1),
             actual_completion_date: Date.new(2019, 10, 3),
             description: 'a longer description',
             access_information: 'The communal door will be unlocked',
             created_at: Time.utc(2017, 10, 1, 12, 13, 55),
             added_at: Time.utc(2017, 10, 1, 11, 13, 55))
    end

    it 'returns a CSV of all defects ordered by created_at' do
      expected_csv = File.read('spec/fixtures/download_defects.csv')
      generated_csv = Defect.to_csv(defects: [communal_defect, property_defect])

      expect(generated_csv).to eq(expected_csv)
    end
  end

  describe '.csv_headers' do
    it 'returns all defects' do
      expect(described_class.csv_headers).to eq(
        %w[
          reference_number
          date_created
          date_added
          title
          type
          status
          trade
          category
          priority_name
          priority_duration
          target_completion_date
          actual_completion_date
          estate
          scheme
          property_address
          communal_area_name
          communal_area_location
          description
          access_information
          escalated_defects
        ]
      )
    end
  end

  describe '.send_chain' do
    it 'sends each symbol as a method to Defect' do
      expect(described_class).to receive(:all)
      described_class.send_chain([:all])
    end

    context 'when there is an nested array of parameters' do
      it 'sends the symbol as a method, with the parameters' do
        expect(TestDefect).to receive(:any_scope).with(%w[foo bar])
        TestDefect.send_chain([:all, [:any_scope, %w[foo bar]]])
      end
    end
  end

  describe '.contact_phone_number=' do
    it 'strips whitespace' do
      defect = described_class.new
      defect.contact_phone_number = '123 456'
      expect(defect.contact_phone_number).to eq('123456')
    end

    context 'when there is no value' do
      it 'returns nil' do
        defect = described_class.new
        defect.contact_phone_number = nil
        expect(defect.contact_phone_number).to eq(nil)
      end
    end
  end

  describe '::TRADES' do
    it 'includes all the trades, and only those trades, that are in trades by category' do
      expect(
        Defect::ELECTRICAL_TRADES +
        Defect::PLUMBING_TRADES +
        Defect::CARPENTRY_TRADES +
        Defect::COSMETIC_TRADES
      ).to match_array(Defect::TRADES)
    end

    it 'does not have duplicates' do
      expect(Defect::TRADES).to eq(Defect::TRADES.uniq)
    end

    it 'is sorted alphabetically' do
      expect(Defect::TRADES).to eq(Defect::TRADES.sort)
    end
  end

  describe '.set_created_at' do
    it 'sets the created_at' do
      defect = build(:defect)
      defect.set_created_at(Date.new(2019, 1, 1))
      expect(defect.created_at).to eq('2019-1-1')
    end
  end
end
