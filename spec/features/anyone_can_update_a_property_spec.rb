require 'rails_helper'

RSpec.feature 'Anyone can update a property' do
  let!(:scheme) { create(:scheme) }

  scenario 'a property can be udpated' do
    create(:property, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.properties') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_property') do
      fill_in 'property[address]', with: 'Flat 1, Hackney Street'
      fill_in 'property[postcode]', with: 'N16NU'
      click_on(I18n.t('generic.button.update', resource: 'Property'))
    end
  end

  scenario 'an invalid property cannot be updated' do
    create(:property, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.properties') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_property') do
      fill_in 'property[address]', with: ''
      fill_in 'property[postcode]', with: ''

      click_on(I18n.t('generic.button.update', resource: 'Property'))
    end

    within('.property_address') do
      expect(page).to have_content("can't be blank")
    end

    within('.property_postcode') do
      expect(page).to have_content("can't be blank")
    end
  end
end
