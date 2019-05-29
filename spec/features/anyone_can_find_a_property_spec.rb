require 'rails_helper'

RSpec.feature 'Anyone can find a property' do
  scenario 'with an address' do
    scheme = create(:scheme)
    interested_property = create(:property, scheme: scheme, address: '1 Hackney Street')
    uninterested_property = create(:property, scheme: scheme, address: '60 London Road')

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.property-search') do
      fill_in 'address', with: 'Hackney'
      click_on(I18n.t('generic.button.find'))
    end

    within('table.properties') do
      expect(page).to have_content(interested_property.address)
      expect(page).not_to have_content(uninterested_property.address)
    end
  end
end
