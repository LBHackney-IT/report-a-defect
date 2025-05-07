require 'rails_helper'

RSpec.feature 'Staff can flag a communal defect' do
  before(:each) do
    stub_authenticated_session(name: 'Bob')
  end

  context 'flagging a defect' do
    let(:defect) { create(:communal_defect, flagged: false) }

    before do
      visit communal_area_defect_url(defect.communal_area, defect)
      click_button I18n.t('button.flag.add')
    end

    it 'marks the defect as flagged' do
      expect(defect.reload).to be_flagged
    end

    it 'shows the flag being added in the activity log' do
      within('.events') do
        expect(page).to have_content(
          I18n.t('events.defect.flag_added', name: 'Bob')
        )
      end
    end

    it 'shows the flag in the list of defects' do
      visit defects_url

      within('table.defects tbody th:first-child') do
        expect(page).to have_content('Flagged')
      end
    end
  end

  context 'unflagging a defect' do
    let(:defect) { create(:communal_defect, flagged: true) }

    before do
      visit communal_area_defect_url(defect.communal_area, defect)
      click_button I18n.t('button.flag.remove')
    end

    it 'removes the flag from the defect' do
      expect(defect.reload).not_to be_flagged
    end

    it 'shows the flag being removed in the activity log' do
      within('.events') do
        expect(page).to have_content(
          I18n.t('events.defect.flag_removed', name: 'Bob')
        )
      end
    end

    it 'does not show a flag in the list of defects' do
      visit defects_url

      within('table.defects tbody th:first-child') do
        expect(page).not_to have_content('Flagged')
      end
    end
  end
end
