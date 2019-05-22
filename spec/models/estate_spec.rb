require 'rails_helper'

RSpec.describe Estate, type: :model do
  it { should have_many(:schemes) }
  it 'validates presence of required fields' do
    blank_repair = described_class.new
    expect(blank_repair.valid?).to be_falsey

    errors = blank_repair.errors.full_messages

    expect(errors).to include("Name can't be blank")
  end
end
