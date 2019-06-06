require 'rails_helper'

RSpec.describe SaveDefect do
  describe '.initialize' do
    it 'accepts and stores the defect' do
      defect = create(:defect)

      result = described_class.new(defect: defect)

      expect(result.defect).to eq(defect)
    end
  end

  describe '#call' do
    let(:defect) { create(:defect) }

    it 'saves the record' do
      expect(defect).to receive(:save)
      described_class.new(defect: defect).call
    end

    it 'sends an email to the contractor' do

    end
  end
end
