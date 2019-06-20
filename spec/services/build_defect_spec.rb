require 'rails_helper'

RSpec.describe BuildDefect do
  let(:property) { create(:property) }
  let(:block) { create(:block) }
  let(:priority) { create(:priority) }
  let(:defect_params) do
    build(:property_defect,
          property: property,
          block: block,
          priority: priority).attributes
  end

  describe '.initialize' do
    it 'accepts and stores the defect_params' do
      result = described_class.new(defect_params: defect_params)

      expect(result.defect_params).to eq(defect_params)
    end
  end

  describe '#call' do
    let(:service) do
      described_class.new(defect_params: defect_params)
    end

    it 'returns a defect object' do
      expect(service.call).to be_kind_of(Defect)
    end

    it 'creates an association to the property' do
      result = service.call
      expect(result.property).to eq(property)
    end

    it 'creates an association to the priority' do
      result = service.call
      expect(result.priority).to eq(priority)
    end

    it 'creates an association to the block' do
      result = service.call
      expect(result.block).to eq(block)
    end
  end
end
