require 'rails_helper'

RSpec.feature 'Anyone can create a property' do
  let!(:scheme) { create(:scheme) }

  scenario 'a property can be created' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('generic.button.create', resource: 'Property'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.create'))
    within('form.new_property') do
      fill_in 'property[core_name]', with: 'A name for a collection of blocks'
      fill_in 'property[address]', with: 'Flat 1, Hackney Street'
      fill_in 'property[postcode]', with: 'N16NU'
      click_on(I18n.t('generic.button.create', resource: 'Property'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'property'))
    within('table.properties') do
      property = Property.first
      expect(page).to have_content(property.core_name)
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.postcode)
    end
  end

  scenario 'an invalid property cannot be submitted' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('generic.button.create', resource: 'Property'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.create'))
    within('form.new_property') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Property'))
    end

    within('.property_core_name') do
      expect(page).to have_content("can't be blank")
    end

    within('.property_address') do
      expect(page).to have_content("can't be blank")
    end

    within('.property_postcode') do
      expect(page).to have_content("can't be blank")
    end
  end
end
