require 'rails_helper'

RSpec.describe Priority, type: :model do
  it { should belong_to(:scheme) }
  it 'validates presence of required fields' do
    blank_repair = described_class.new
    expect(blank_repair.valid?).to be_falsey

    errors = blank_repair.errors.full_messages

    expect(errors).to include("Name can't be blank")
    expect(errors).to include("Duration can't be blank")
    expect(errors).to include('Scheme must exist')
  end
end
