require 'rails_helper'

RSpec.feature 'Anyone can view a property' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a property can be found and viewed' do
    property = create(:property, address: '1 Hackney Street')

    visit dashboard_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Hackney'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.show', name: property.address))

    within('.scheme_short_information') do
      expect(page).to have_content(property.scheme.name)
      expect(page).to have_content(property.scheme.contractor_name)
      expect(page).to have_content(property.scheme.employer_agent_name)
    end

    within('.property_information') do
      expect(page).to have_content(property.uprn)
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.postcode)
    end
  end

  scenario 'can use breadcrumbs to navigate' do
    property = create(:property)

    visit property_path(property)

    within('.govuk-breadcrumbs') do
      expect(page).to have_link('Home', href: '/dashboard')
      expect(page).to have_link(
        I18n.t('page_title.staff.estates.show', name: property.scheme.estate.name),
        href: estate_path(property.scheme.estate)
      )
      expect(page).to have_link(
        I18n.t('page_title.staff.schemes.show', name: property.scheme.name),
        href: estate_scheme_path(property.scheme.estate, property.scheme)
      )
    end
  end
end
