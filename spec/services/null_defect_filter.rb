require 'rails_helper'

RSpec.describe NullDefectFilter do
  describe '#scope' do
    it 'returns :all' do
      result = described_class.new.scope
      expect(result).to eql(:all)
    end
  end
end
