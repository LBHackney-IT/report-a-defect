require 'rails_helper'

RSpec.describe Property, type: :model do
  it { should belong_to(:scheme) }
  it { should have_many(:defects) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    priority = described_class.new
    expect(priority.valid?).to be_falsey

    errors = priority.errors.full_messages

    expect(errors).to include("Core name can't be blank")
    expect(errors).to include("Address can't be blank")
    expect(errors).to include("Postcode can't be blank")
  end
end
