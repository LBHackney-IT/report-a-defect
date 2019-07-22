require 'rails_helper'

RSpec.describe ReportForm do
  let(:from_date) { Date.new(2019, 1, 1) }
  let(:to_date) { Date.new(2019, 12, 1) }

  describe '.initialize' do
    context 'when the from_date is a time' do
      it 'returns a date' do
        result = described_class.new(from_date: Time.current, to_date: to_date)
        expect(result.from_date.class).to eq(Date)
      end
    end

    context 'when the to_date is a time' do
      it 'returns a date' do
        result = described_class.new(from_date: from_date, to_date: Time.current)
        expect(result.to_date.class).to eq(Date)
      end
    end
  end
end
