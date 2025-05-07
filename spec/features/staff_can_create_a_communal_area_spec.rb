require 'rails_helper'

RSpec.feature 'Staff can create a communal_area' do
  before(:each) do
    stub_authenticated_session
  end

  let!(:scheme) { create(:scheme) }

  scenario 'a communal_area can be created' do
    visit estate_scheme_url(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('button.create.communal_area'))

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.create'))
    expect(page).to have_content(I18n.t('form.communal_area.explanation'))
    within('form.new_communal_area') do
      fill_in 'communal_area[name]', with: 'Chipping'
      fill_in 'communal_area[location]', with: '22-25 Chipping Road'
      click_on(I18n.t('button.create.communal_area'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'Communal Area'))
    within('table.communal_areas') do
      expect(page).to have_content('Chipping')
      expect(page).to have_content('22-25 Chipping Road')
    end
  end

  scenario 'an invalid communal_area cannot be submitted' do
    visit estate_scheme_url(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('button.create.communal_area'))

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.create'))
    within('form.new_communal_area') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.communal_area'))
    end

    within('.communal_area_name') do
      expect(page).to have_content("can't be blank")
    end

    within('.communal_area_location') do
      expect(page).to have_content("can't be blank")
    end
  end
end
