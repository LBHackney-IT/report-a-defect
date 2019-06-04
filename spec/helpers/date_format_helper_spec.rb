require 'rails_helper'

RSpec.describe DateHelper, type: :helper do
  describe '#format_date' do
    it 'returns the date in the default format' do
      expect(helper.format_date(Date.new(2017, 10, 7))).to eq '7 October 2017'
    end
  end
end
