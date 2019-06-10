require 'rails_helper'

RSpec.feature 'Contractor can accept the receipt of a defect' do
  context 'with the correct token' do
    it 'shows a confirmation page' do
      defect = create(:defect)

      visit defect_accept_path(defect.token)

      expect(page).to have_content(I18n.t('page_title.contractor.defects.accepted.title'))
    end

    it 'stores an accepted at event' do
      travel_to Time.zone.parse('2019-05-23')

      defect = create(:defect)

      visit defect_accept_path(defect.token)

      result = PublicActivity::Activity.find_by(
        trackable_id: defect.id,
        trackable_type: Defect.to_s,
        key: 'defect.accepted'
      )
      expect(result).to be_kind_of(PublicActivity::Activity)
      expect(result.trackable).to be_kind_of(Defect)
      expect(result.created_at).to eq(Time.zone.now)

      travel_back
    end
  end
end
