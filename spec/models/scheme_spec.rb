require 'rails_helper'

RSpec.describe Scheme, type: :model do
  it { should belong_to(:estate) }
  it { should have_many(:priorities) }
  it { should have_many(:properties) }
  it 'validates presence of required fields' do
    scheme = described_class.new
    expect(scheme.valid?).to be_falsey

    errors = scheme.errors.full_messages

    expect(errors).to include("Name can't be blank")
  end
end
