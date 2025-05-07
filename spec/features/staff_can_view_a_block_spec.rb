require 'rails_helper'

RSpec.feature 'Staff can view a communal_area' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a communal_area can be found and viewed' do
    communal_area = create(:communal_area, name: 'Chipping')

    visit dashboard_url

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Chipping'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.show', name: communal_area.name))

    within('.communal_area_information') do
      expect(page).to have_content(communal_area.name)
    end

    expect(page).to have_content(I18n.t('page_content.defect.communal_area.table.header'))
  end

  scenario 'can use breadcrumbs to navigate' do
    communal_area = create(:communal_area)

    visit communal_area_url(communal_area)

    within('.govuk-breadcrumbs') do
      expect(page).to have_link('Home', href: '/dashboard')
      expect(page).to have_link(
        I18n.t('page_title.staff.estates.show', name: communal_area.scheme.estate.name),
        href: estate_url(communal_area.scheme.estate)
      )
      expect(page).to have_link(
        I18n.t('page_title.staff.schemes.show', name: communal_area.scheme.name),
        href: estate_scheme_url(communal_area.scheme.estate, communal_area.scheme)
      )
    end
  end
end
