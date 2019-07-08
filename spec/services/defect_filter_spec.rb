require 'rails_helper'

RSpec.describe DefectFilter do
  describe '#scopes' do
    context 'when all filters are provided' do
      it 'returns an array of all required Defect scopes' do
        result = described_class.new(
          statuses: %i[open closed],
        )
        expect(result.scopes).to eq(
          %i[
            open_and_closed
          ]
        )
      end
    end

    describe 'status' do
      context 'when the statuses are both open and closed' do
        it 'returns :open_and_closed' do
          result = described_class.new(statuses: %i[open closed])
          expect(result.scopes).to eq([:open_and_closed])
        end
      end

      context 'when the status is only open' do
        it 'returns an array with :open' do
          result = described_class.new(statuses: %i[open])
          expect(result.scopes).to eq([:open])
        end
      end

      context 'when the status is only closed' do
        it 'returns an array with :closed' do
          result = described_class.new(statuses: %i[closed])
          expect(result.scopes).to eq([:closed])
        end
      end

      context 'when the status is neither' do
        it 'returns an empty array' do
          result = described_class.new(statuses: %i[foo])
          expect(result.scopes).to eq([])
        end
      end

      context 'when there are no statuses' do
        it 'returns an empty array' do
          result = described_class.new(statuses: %i[])
          expect(result.scopes).to eq([])
        end
      end
    end
  end
end
