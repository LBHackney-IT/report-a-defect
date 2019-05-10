require 'rails_helper'

RSpec.describe Scheme, type: :model do
  it 'validates presence of required fields' do
    blank_repair = described_class.new
    expect(blank_repair.valid?).to be_falsey
  end
end
