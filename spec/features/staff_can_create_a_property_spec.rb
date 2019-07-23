require 'rails_helper'

RSpec.feature 'Staff can create a property' do
  before(:each) do
    stub_authenticated_session
  end

  let!(:scheme) { create(:scheme) }

  scenario 'a property can be created' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('button.create.property'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.create'))
    expect(page).to have_content(I18n.t('form.property.guidance', link: "Hackney's property lookup service"))
    expect(page).to have_link("Hackney's property lookup service", href: 'http://lbhgisnetp01/SinglePoint/SimpleSearch.aspx')

    within('form.new_property') do
      fill_in 'property[address]', with: 'Flat 1, Hackney Street'
      fill_in 'property[postcode]', with: 'N16NU'
      fill_in 'property[uprn]', with: '100081272892'
      click_on(I18n.t('button.create.property'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'property'))
    within('table.properties') do
      expect(page).to have_content('Flat 1, Hackney Street')
      expect(page).to have_content('N16NU')
      expect(page).to have_content('100081272892')
    end
  end

  scenario 'an invalid property cannot be submitted' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('button.create.property'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.create'))
    within('form.new_property') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.property'))
    end

    within('.property_address') do
      expect(page).to have_content("can't be blank")
    end

    within('.property_postcode') do
      expect(page).to have_content("can't be blank")
    end

    within('.property_uprn') do
      expect(page).to have_content("can't be blank")
    end
  end
end
