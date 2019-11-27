require 'rails_helper'

RSpec.describe BuildDate do
  describe '#call' do
    context 'a complete date is given' do
      it 'returns a date' do
        date = BuildDate.new(day: 1, month: 1, year: 1999)
        expect(date.call).to eq(Date.new(1999, 1, 1))
      end
    end
    context 'part of the date is missing' do
      it 'returns nil' do
        date = BuildDate.new(day: 1, year: 1999)
        expect(date.call).to eq(nil)
      end
    end
  end
end
