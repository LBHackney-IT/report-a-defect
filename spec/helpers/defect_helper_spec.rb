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
end
