require 'rails_helper'

RSpec.describe Block, type: :model do
  it { should belong_to(:scheme) }

  it_behaves_like 'a trackable resource', resource: described_class
end
