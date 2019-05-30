require 'rails_helper'

RSpec.feature 'Anyone can create a defect' do
  scenario 'a property can be found and defect can be created' do
    property = create(:property, address: '1 Hackney Street')

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.property-search') do
      fill_in 'address', with: 'Hackney'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.show', name: property.address))

    within('.property_information') do
      expect(page).to have_content(property.scheme.estate.name)
      expect(page).to have_content(property.scheme.name)
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.core_name)
    end
  end
end