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

      expect(defect.reload.target_completion_date).to eq(Date.new(2019, 5, 25))

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
end
