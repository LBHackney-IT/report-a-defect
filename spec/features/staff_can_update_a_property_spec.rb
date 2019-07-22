require 'rails_helper'

RSpec.feature 'Staff can update a property' do
  before(:each) do
    stub_authenticated_session
  end

  let!(:scheme) { create(:scheme) }

  scenario 'a property can be udpated' do
    create(:property, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.properties') do
      click_on(I18n.t('generic.link.edit'))
    end

    expect(page).to have_content(I18n.t('form.property.guidance', link: "Hackney's property lookup service"))
    expect(page).to have_link("Hackney's property lookup service", href: 'http://lbhgisnetp01/SinglePoint/SimpleSearch.aspx')

    within('form.edit_property') do
      fill_in 'property[address]', with: 'Flat 1, Hackney Street'
      fill_in 'property[postcode]', with: 'N16NU'
      click_on(I18n.t('button.update.property'))
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

      click_on(I18n.t('button.update.property'))
    end

    within('.property_address') do
      expect(page).to have_content("can't be blank")
    end

    within('.property_postcode') do
      expect(page).to have_content("can't be blank")
    end
  end
end
