require 'rails_helper'

RSpec.describe Evidence, type: :model do
  it { should belong_to(:defect) }

  it 'validates presence of required fields' do
    comment = described_class.new
    expect(comment.valid?).to be_falsey

    errors = comment.errors.full_messages

    expect(errors).to include("Description can't be blank")
    expect(errors).to include("Supporting file can't be blank")
  end
end
