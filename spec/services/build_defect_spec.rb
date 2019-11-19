require 'rails_helper'

RSpec.describe BuildDefect do
  let(:property) { create(:property) }
  let(:communal_area) { create(:communal_area) }
  let(:priority) { create(:priority) }
  let(:defect_params) do
    build(:property_defect,
          property: property,
          communal_area: communal_area,
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

    it 'creates an association to the communal_area' do
      result = service.call
      expect(result.communal_area).to eq(communal_area)
    end

    context 'when the created on date is set' do
      let(:service) do
        described_class.new(
          defect_params: defect_params,
          options: { created_at: { day: 25, month: 12, year: 2018 } }
        )
      end

      it 'updates the created_at date' do
        result = service.call
        expect(result.created_at).to eq(Date.new(2018, 12, 25))
      end
    end
  end
end
