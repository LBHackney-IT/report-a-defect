require 'rails_helper'

RSpec.feature 'Anyone can view a scheme' do
  scenario 'a scheme can be found and viewed' do
    scheme = create(:scheme)
    property = create(:property, scheme: scheme)
    priority = create(:priority, scheme: scheme)

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))
    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: scheme.estate.name))
    click_on(I18n.t('generic.link.show').titleize)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name).titleize)

    within('.scheme_information') do
      expect(page).to have_content(scheme.name)
      expect(page).to have_content(scheme.contractor_name)
      expect(page).to have_content(scheme.contractor_email_address)
    end

    within('.priorities') do
      expect(page).to have_content(priority.name)
      expect(page).to have_content(priority.days)
    end

    within('.properties') do
      expect(page).to have_content(property.core_name)
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.postcode)
    end
  end
end
