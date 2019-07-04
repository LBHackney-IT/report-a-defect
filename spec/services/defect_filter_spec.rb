require 'rails_helper'

RSpec.describe DefectFilter do
  describe '#scope' do
    context 'when the status are both open and closed' do
      it 'returns :all' do
        result = described_class.new(statuses: %i[open closed])
        expect(result.scope).to eq(:all)
      end
    end

    context 'when the status is only open' do
      it 'returns :open' do
        result = described_class.new(statuses: %i[open])
        expect(result.scope).to eq(:open)
      end
    end

    context 'when the status is only closed' do
      it 'returns :closed' do
        result = described_class.new(statuses: %i[closed])
        expect(result.scope).to eq(:closed)
      end
    end

    context 'when the status is neither' do
      it 'returns :none' do
        result = described_class.new(statuses: %i[foo])
        expect(result.scope).to eq(:none)
      end
    end

    context 'when there are no statuses' do
      it 'returns :none' do
        result = described_class.new(statuses: %i[])
        expect(result.scope).to eq(:none)
      end
    end
  end

  describe '#none?' do
    context 'when there are no statuses' do
      it 'returns true' do
        result = described_class.new(statuses: [])
        expect(result.none?).to eq(true)
      end
    end

    context 'when there is at least one status' do
      it 'returns false' do
        result = described_class.new(statuses: [:foo])
        expect(result.none?).to eq(false)
      end
    end
  end

  describe '#open?' do
    context 'when there is an open status' do
      it 'returns true' do
        result = described_class.new(statuses: [:open])
        expect(result.open?).to eq(true)
      end
    end

    context 'when open is not an included status' do
      it 'returns false' do
        result = described_class.new(statuses: [:foo])
        expect(result.open?).to eq(false)
      end
    end
  end

  describe '#closed' do
    context 'when there is an closed status' do
      it 'returns true' do
        result = described_class.new(statuses: [:closed])
        expect(result.closed?).to eq(true)
      end
    end

    context 'when closed is not an included status' do
      it 'returns false' do
        result = described_class.new(statuses: [:foo])
        expect(result.closed?).to eq(false)
      end
    end
  end
end
