require 'rails_helper'

RSpec.describe DatetimeHelper, type: :helper do
  describe '#format_date' do
    it 'returns the date in the default format' do
      expect(helper.format_date(Date.new(2017, 10, 7))).to eq '7 October 2017'
    end
  end

  describe '#format_time' do
    it 'returns the time and date in the default format' do
      expect(helper.format_time(Time.zone.local(2017, 10, 7, 9, 45)))
        .to eq 'at 09:45am on 7 October 2017'
    end
  end
end
