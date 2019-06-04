require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:comments) }

  it_behaves_like 'a trackable resource', resource: described_class
end
