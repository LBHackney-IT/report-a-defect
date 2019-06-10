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

  context 'with an incorrect token' do
    it 'returns a custom unprocessable_entity error' do
      visit defect_accept_path('an-unknown-token')
      expect(page.status_code).to eq(422)
      expect(page).to have_content(I18n.t('page_title.contractor.defects.unprocessable_entity.body'))
    end
  end

  context 'when this token has expired' do
    it 'returns a custom unprocessable_entity error' do
      travel_to Time.zone.parse('2019-01-01')

      defect = create(:defect)
      token = defect.token

      travel_to Time.zone.parse('2019-04-01')

      visit defect_accept_path(token)
      expect(page.status_code).to eq(422)
      expect(page).to have_content(I18n.t('page_title.contractor.defects.unprocessable_entity.body'))

      travel_back
    end
  end

  context 'when this token has already been used'

  context 'when the token contains suspicious characters'

  #
  # context 'with the incorrect token' do
  #   let(:token) { subscription.id }
  #
  #   it 'returns not found' do
  #     expect(page.status_code).to eq(404)
  #   end
  # end
  #
  # context 'with an old token' do
  #   let(:token) do
  #     Timecop.travel(-3.days) { subscription.token }
  #   end
  #
  #   scenario 'still returns 200' do
  #     expect(page.status_code).to eq(200)
  #   end
  # end
end
