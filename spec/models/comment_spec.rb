require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should belong_to(:defect) }
  it { should belong_to(:user) }

  it_behaves_like 'a trackable resource', resource: described_class

  it 'validates presence of required fields' do
    comment = described_class.new
    expect(comment.valid?).to be_falsey

    errors = comment.errors.full_messages

    expect(errors).to include("Message can't be blank")
  end
end
