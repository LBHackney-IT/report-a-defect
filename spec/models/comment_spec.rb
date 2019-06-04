require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should belong_to(:defect) }
  it { should belong_to(:user) }

  it_behaves_like 'a trackable resource', resource: described_class
end
