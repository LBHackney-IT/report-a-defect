require 'rails_helper'

RSpec.describe CommunalArea, type: :model do
  it { should belong_to(:scheme) }
  it { should have_many(:defects) }

  it_behaves_like 'a trackable resource', resource: :communal_area

  it 'validates presence of required fields' do
    communal_area = described_class.new
    expect(communal_area.valid?).to be_falsey

    errors = communal_area.errors.full_messages

    expect(errors).to include("Name can't be blank")
  end
end
