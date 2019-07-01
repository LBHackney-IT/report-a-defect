require 'rails_helper'

RSpec.describe DatetimeHelper, type: :helper do
  describe '#format_date' do
    it 'returns the date in the default format' do
      expect(helper.format_date(Date.new(2017, 10, 7))).to eq '7 October 2017'
    end
  end

  describe '#format_time_in_sentence' do
    it 'returns the time and date in the default format' do
      expect(helper.format_time_in_sentence(Time.zone.local(2017, 10, 7, 9, 45)))
        .to eq 'on 7 October 2017 at 09:45'
    end

    context 'when the time zone is BST' do
      it 'renders the time +1 hour on top of UTC' do
        time = Time.utc(2017, 10, 7, 9, 45)
        expect(helper.format_time_in_sentence(time))
          .to eq 'on 7 October 2017 at 10:45'
      end
    end
  end
end
