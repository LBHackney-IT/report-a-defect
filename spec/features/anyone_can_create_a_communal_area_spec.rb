require 'rails_helper'

RSpec.feature 'Anyone can create a communal_area' do
  let!(:scheme) { create(:scheme) }

  scenario 'a communal_area can be created' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('generic.button.create', resource: 'Communal Area'))

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.create'))
    within('form.new_communal_area') do
      fill_in 'communal_area[name]', with: 'Chipping'
      click_on(I18n.t('generic.button.create', resource: 'Communal Area'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'Communal Area'))
    within('table.communal_areas') do
      expect(page).to have_content('Chipping')
    end
  end

  scenario 'an invalid communal_area cannot be submitted' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('generic.button.create', resource: 'Communal Area'))

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.create'))
    within('form.new_communal_area') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Communal Area'))
    end

    within('.communal_area_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
