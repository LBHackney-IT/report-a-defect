require 'rails_helper'

RSpec.describe Repair, type: :model do
  it 'validates presence of description' do
    blank_repair = described_class.new
    expect(blank_repair.valid?).to be_falsey
  end
end
