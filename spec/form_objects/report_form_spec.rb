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

  describe '#from_day' do
    it 'returns the from day' do
      result = described_class.new(from_date: from_date, to_date: to_date).from_day
      expect(result).to eql(1)
    end
  end

  describe '#from_month' do
    it 'returns the from month' do
      result = described_class.new(from_date: from_date, to_date: to_date).from_month
      expect(result).to eql(1)
    end
  end

  describe '#from_year' do
    it 'returns the from year' do
      result = described_class.new(from_date: from_date, to_date: to_date).from_year
      expect(result).to eql(2019)
    end
  end

  describe '#to_day' do
    it 'returns the to day' do
      result = described_class.new(from_date: from_date, to_date: to_date).to_day
      expect(result).to eql(1)
    end
  end

  describe '#to_month' do
    it 'returns the to month' do
      result = described_class.new(from_date: from_date, to_date: to_date).to_month
      expect(result).to eql(12)
    end
  end

  describe '#to_year' do
    it 'returns the to year' do
      result = described_class.new(from_date: from_date, to_date: to_date).to_year
      expect(result).to eql(2019)
    end
  end
end
