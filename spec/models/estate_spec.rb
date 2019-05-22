require 'rails_helper'

RSpec.describe Estate, type: :model do
  it { should have_many(:schemes) }
  it 'validates presence of required fields' do
    estate = described_class.new
    expect(estate.valid?).to be_falsey

    errors = estate.errors.full_messages

    expect(errors).to include("Name can't be blank")
  end
end
