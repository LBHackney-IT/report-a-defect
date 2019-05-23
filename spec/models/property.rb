require 'rails_helper'

RSpec.describe Property, type: :model do
  it { should belong_to(:scheme) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    priority = described_class.new
    expect(priority.valid?).to be_falsey

    errors = priority.errors.full_messages

    expect(errors).to include("Name can't be blank")
    expect(errors).to include("Days can't be blank")
    expect(errors).to include('Scheme must exist')
  end
end
