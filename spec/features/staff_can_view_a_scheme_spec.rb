require 'rails_helper'

RSpec.feature 'Staff can view a scheme' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a scheme can be found and viewed' do
    scheme = create(:scheme)
    property = create(:property, scheme: scheme)
    communal_area = create(:communal_area, scheme: scheme)
    priority = create(:priority, scheme: scheme)

    visit dashboard_url

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))
    within('.estates') do
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: scheme.estate.name))
    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('.scheme_information.scheme_name_and_estate') do
      expect(page).to have_content(scheme.estate.name)
      expect(page).to have_content(scheme.name)
    end

    within('.scheme_information.scheme_contractor') do
      expect(page).to have_content(scheme.contractor_name)
      expect(page).to have_content(scheme.contractor_email_address)
    end

    within('.scheme_information.scheme_agent') do
      expect(page).to have_content(scheme.employer_agent_name)
      expect(page).to have_content(scheme.employer_agent_email_address)
    end

    within('.priorities') do
      expect(page).to have_content(priority.name)
      expect(page).to have_content(priority.days)
    end

    within('.properties') do
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.postcode)
    end

    within('.communal_areas') do
      expect(page).to have_content(communal_area.name)
    end
  end

  scenario 'can use breadcrumbs to navigate' do
    scheme = create(:scheme)

    visit estate_scheme_url(scheme.estate, scheme)

    within('.govuk-breadcrumbs') do
      expect(page).to have_link('Home', href: '/dashboard')
      expect(page).to have_link(
        I18n.t('page_title.staff.estates.show', name: scheme.estate.name),
        href: estate_url(scheme.estate)
      )
    end
  end

  scenario 'when there are no priorities' do
    scheme = create(:scheme)

    visit estate_scheme_url(scheme.estate, scheme)
    within('.scheme-priorities') do
      expect(page).to have_content(
        I18n.t('page_content.scheme.show.priorities.no_priorities')
      )
    end
  end
end
