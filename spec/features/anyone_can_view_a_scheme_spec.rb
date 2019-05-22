require 'rails_helper'

RSpec.feature 'Anyone can view a scheme' do
  let!(:estate) { create(:estate) }

  scenario 'a scheme can be viewed' do
    scheme = create(:scheme, estate: estate)

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('table.estates') do
      expect(page).to have_content(estate.name)
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: estate.name).titleize)

    within('table.schemes') do
      expect(page).to have_content(scheme.name)
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name).titleize)
  end
end
