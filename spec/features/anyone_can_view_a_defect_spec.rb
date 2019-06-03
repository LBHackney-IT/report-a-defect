require 'rails_helper'

RSpec.feature 'Anyone can view a defect' do
  scenario 'a defect can be found and viewed' do
    defect = create(:defect)

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.property-search') do
      fill_in 'address', with: defect.property.address
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    within('.defects') do
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    within('.defect_information') do
      expect(page).to have_content(defect.reference_number)
      expect(page).to have_content(defect.description)
      expect(page).to have_content(defect.contact_name)
      expect(page).to have_content(defect.contact_phone_number)
      expect(page).to have_content(defect.contact_email_address)
      expect(page).to have_content(defect.trade)
      expect(page).to have_content(defect.priority.name)
      expect(page).to have_content(defect.target_completion_date)
      expect(page).to have_content(defect.status)
    end

    within('.scheme_information') do
      expect(page).to have_content(defect.property.scheme.estate.name)
      expect(page).to have_content(defect.property.scheme.name)
      expect(page).to have_content(defect.property.scheme.contractor_name)
      expect(page).to have_content(defect.property.scheme.contractor_email_address)
      expect(page).to have_content(defect.property.scheme.employer_agent_name)
      expect(page).to have_content(defect.property.scheme.employer_agent_email_address)
    end

    within('.property_information') do
      expect(page).to have_content(defect.property.uprn)
      expect(page).to have_content(defect.property.address)
      expect(page).to have_content(defect.property.core_name)
      expect(page).to have_content(defect.property.postcode)
    end
  end

  scenario 'can use breadcrumbs to navigate' do
    defect = create(:defect)

    visit property_defect_path(defect.property, defect)

    within('.govuk-breadcrumbs') do
      expect(page).to have_link('Home', href: '/')

      expect(page).to have_link(
        I18n.t('page_title.staff.estates.show', name: defect.property.scheme.estate.name),
        href: estate_path(defect.property.scheme.estate)
      )
      expect(page).to have_link(
        I18n.t('page_title.staff.schemes.show', name: defect.property.scheme.name),
        href: estate_scheme_path(defect.property.scheme.estate, defect.property.scheme)
      )
      expect(page).to have_link(
        I18n.t('page_title.staff.properties.show', name: defect.property.address),
        href: property_path(defect.property)
      )
      expect(page).to have_content(
        I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number)
      )
    end
  end
end
