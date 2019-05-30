require 'rails_helper'

RSpec.describe Defect, type: :model do
  it { should belong_to(:property) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    defect = described_class.new
    expect(defect.valid?).to be_falsey

    errors = defect.errors.full_messages

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

  it 'validates that contact email address looks like one' do

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
end
