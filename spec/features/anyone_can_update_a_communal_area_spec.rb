require 'rails_helper'

RSpec.feature 'Anyone can update a communal_area' do
  let!(:scheme) { create(:scheme) }

  scenario 'a communal_area can be udpated' do
    create(:communal_area, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.communal_areas') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_communal_area') do
      fill_in 'communal_area[name]', with: 'Darling'
      fill_in 'communal_area[location]', with: 'Darling Estate'
      click_on(I18n.t('generic.button.update', resource: 'Communal Area'))
    end
  end

  scenario 'an invalid communal_area cannot be updated' do
    create(:communal_area, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.communal_areas') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_communal_area') do
      fill_in 'communal_area[name]', with: ''
      fill_in 'communal_area[location]', with: ''

      click_on(I18n.t('generic.button.update', resource: 'Communal Area'))
    end

    within('.communal_area_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
