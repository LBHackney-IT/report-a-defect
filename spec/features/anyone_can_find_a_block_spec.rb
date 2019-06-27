require 'rails_helper'

RSpec.feature 'Anyone can find a communal_area' do
  scenario 'with a name' do
    scheme = create(:scheme)
    interested_communal_area = create(:communal_area, scheme: scheme, name: 'Clift House')
    uninterested_communal_area = create(:communal_area, scheme: scheme, name: 'Darling House')

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Clift'
      click_on(I18n.t('generic.button.find'))
    end

    within('table.communal_areas') do
      expect(page).to have_content(interested_communal_area.name)
      expect(page).not_to have_content(uninterested_communal_area.name)
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.show', name: interested_communal_area.name))
  end
end
