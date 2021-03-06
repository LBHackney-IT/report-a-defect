require 'rails_helper'

RSpec.describe Scheme, type: :model do
  it { should belong_to(:estate) }
  it { should have_many(:priorities) }
  it { should have_many(:properties) }
  it { should have_many(:communal_areas) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    scheme = described_class.new
    expect(scheme.valid?).to be_falsey

    errors = scheme.errors.full_messages

    expect(errors).to include("Name can't be blank")
    expect(errors).to include("Contractor name can't be blank")
    expect(errors).to include("Contractor email address can't be blank")
  end

  describe 'validates that contractor email address looks like one' do
    it 'returns true with a valid email address' do
      scheme = build(:scheme, contractor_email_address: 'email@example.com')
      expect(scheme.valid?).to be_truthy
    end

    it 'returns false with an invalid email address' do
      scheme = build(:scheme, contractor_email_address: 'not a real email')
      expect(scheme.valid?).to be_falsey
    end
  end

  describe 'validates that employer_agent email address looks like one' do
    it 'returns true with a valid email address' do
      scheme = build(:scheme, employer_agent_email_address: 'email@example.com')
      expect(scheme.valid?).to be_truthy
    end

    it 'returns false with an invalid email address' do
      scheme = build(:scheme, employer_agent_email_address: 'not a real email')
      expect(scheme.valid?).to be_falsey
    end
  end

  describe '.set_start_date' do
    it 'sets the start_date' do
      scheme = build(:scheme)
      scheme.set_start_date(day: 1, month: 2, year: 2019)
      expect(scheme.start_date).to eq(Date.new(2019, 2, 1))
    end
  end
end
