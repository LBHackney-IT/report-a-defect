require 'rails_helper'

RSpec.describe DefectHelper, type: :helper do
  describe '#priority_form_label' do
    it 'returns a string that combines name and how many days in the future it will be' do
      travel_to Time.zone.parse('2019-05-23')

      priority = create(:priority, name: 'P1', days: 3)
      result = helper.priority_form_label(priority: priority)
      expect(result).to eq('P1 - 3 days from now')

      travel_back
    end

    context 'when the target completion date is tomorrow' do
      it 'returns the singular for days' do
        travel_to Time.zone.parse('2019-05-23')

        priority = create(:priority, name: 'P1', days: 1)
        result = helper.priority_form_label(priority: priority)
        expect(result).to eq('P1 - 1 day from now')

        travel_back
      end
    end
  end

  describe '#status_form_label' do
    it 'returns a capitalized string' do
      result = helper.status_form_label(option_array: ['outstanding', 0])
      expect(result).to eql('Outstanding')
    end

    it 'returns a string without underscores' do
      result = helper.status_form_label(option_array: ['end_of_year', 1])
      expect(result).to eql('End of year')
    end
  end

  describe '#view_path_for' do
    let(:property) { create(:property) }
    let(:block) { create(:block) }
    let(:defect) { create(:defect) }

    it 'returns a view path when the parent is a property' do
      result = helper.view_path_for(parent: property, defect: defect)
      expect(result).to eq(property_defect_path(property, defect))
    end

    it 'returns a view path when the parent is a block' do
      result = helper.view_path_for(parent: block, defect: defect)
      expect(result).to eq(block_defect_path(block, defect))
    end

    it 'returns nothing if the parent isn\'t expected' do
      result = helper.view_path_for(parent: double, defect: defect)
      expect(result).to eq(nil)
    end
  end
end
