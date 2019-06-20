require 'rails_helper'

RSpec.describe Block, type: :model do
  it { should belong_to(:scheme) }
  it { should have_many(:defects) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    block = described_class.new
    expect(block.valid?).to be_falsey

    errors = block.errors.full_messages

    expect(errors).to include("Name can't be blank")
  end
end
