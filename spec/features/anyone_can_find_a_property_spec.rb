require 'rails_helper'

RSpec.feature 'Anyone can find a property' do
  scenario 'with an address' do
    scheme = create(:scheme)
    interested_property = create(:property, scheme: scheme, address: '1 Hackney Street')
    uninterested_property = create(:property, scheme: scheme, address: '60 London Road')

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Hackney'
      click_on(I18n.t('generic.button.find'))
    end

    within('table.properties') do
      expect(page).to have_content(interested_property.address)
      expect(page).not_to have_content(uninterested_property.address)
    end
  end

  scenario 'can navigate back to make another search' do
    visit root_path

    within('form.search') do
      fill_in 'query', with: 'Hackney'
      click_on(I18n.t('generic.button.find'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.search.index.headers.main', query: 'Hackney'))

    click_on('Back')

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))
  end
end
