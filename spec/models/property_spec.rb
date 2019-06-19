require 'rails_helper'

RSpec.describe Property, type: :model do
  it { should belong_to(:scheme) }
  it { should have_many(:defects) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    property = described_class.new
    expect(property.valid?).to be_falsey

    errors = property.errors.full_messages

    expect(errors).to include("Address can't be blank")
    expect(errors).to include("Postcode can't be blank")
    expect(errors).to include("UPRN can't be blank")
  end

  context 'when a duplicate UPRN is used' do
    it 'is invalid' do
      _existing_property = create(:property, uprn: '123')
      new_property = described_class.new(uprn: '123')

      expect(new_property.valid?).to be_falsey

      errors = new_property.errors.full_messages

      expect(errors).to include('UPRN has already been taken')
    end
  end
end
