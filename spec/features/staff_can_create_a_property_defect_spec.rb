require 'rails_helper'

RSpec.feature 'Staff can create a defect for a property' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a property can be found and defect can be created', :carrierwave do
    property = create(:property, address: '1 Hackney Street')
    priority = create(:priority, scheme: property.scheme, name: 'P1', days: 1)

    visit dashboard_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Hackney'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.properties.show', name: property.address))

    click_on(I18n.t('button.create.property_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create.property'))

    within('.property_information') do
      expect(page).to have_content(property.uprn)
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.postcode)
    end

    within('form.new_defect') do
      fill_in 'created_at[day]', with: '1'
      fill_in 'created_at[month]', with: '2'
      fill_in 'created_at[year]', with: '2019'
      fill_in 'defect[title]', with: 'Electrics failed'
      fill_in 'defect[description]', with: 'None of the electrics work'
      fill_in 'defect[contact_name]', with: 'Alex Stone'
      fill_in 'defect[contact_email_address]', with: 'email@example.com'
      fill_in 'defect[contact_phone_number]', with: '07123456789'
      select 'Electrical', from: 'defect[trade]'
      choose priority.name
      attach_file 'defect[evidences_attributes][0][supporting_file]', Rails.root.join('spec', 'fixtures', 'evidence.png')
      fill_in 'defect[evidences_attributes][0][description]', with: 'Some uploaded evidence'
      click_on(I18n.t('button.create.property_defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'defect'))
    within('table.defects') do
      defect = property.reload.defects.first

      expect(page).to have_content('Electrics failed')
      expect(page).to have_content('Electrical')
      expect(page).to have_content('Outstanding')
      expect(page).to have_content(priority.name)
      expect(page).to have_content('1 February 2019')
      expect(page).to have_content(defect.target_completion_date)
      expect(page).to have_content(defect.reference_number)
    end

    click_on(I18n.t('generic.link.show'))

    within('.property-location') do
      expect(page).to have_content('Property')
      expect(page).to have_content(property.address)
    end

    within('.evidence') do
      evidence = Evidence.first
      expect(page).to have_content('Some uploaded evidence')
      expect(page).to have_selector(:css, "a[href='#{evidence.supporting_file.url}']")
    end
  end

  scenario 'an invalid defect cannot be submitted' do
    property = create(:property)

    visit property_path(property)

    click_on(I18n.t('button.create.property_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create.property'))
    within('form.new_defect') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.property_defect'))
    end

    within('.defect_description') do
      expect(page).to have_content("can't be blank")
    end

    within('.defect_trade') do
      expect(page).to have_content("can't be blank")
    end

    within('.defect_priority') do
      expect(page).to have_content("can't be blank")
    end
  end

  scenario 'any status can be given' do
    property = create(:property)

    visit property_path(property)

    click_on(I18n.t('button.create.property_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create.property'))

    expected_statues = %w[outstanding completed closed raised_in_error follow_on end_of_year referral rejected dispute]

    within('form.new_defect') do
      expected_statues.each do |status|
        select status.capitalize.tr('_', ' '), from: 'defect[status]'
      end
      click_on(I18n.t('button.create.property_defect'))
    end
  end

  scenario 'a communal defect can be created after finishing the creation of a property defect' do
    property_defect = create(:property_defect)

    # Skip a manual defect creation when it's not the part under test
    visit property_path(property_defect.property)

    expect(page).to have_link(
      I18n.t('button.create.communal_defect'),
      href: estate_scheme_path(property_defect.scheme.estate, property_defect.scheme, anchor: 'communal-areas')
    )
    click_on(I18n.t('button.create.communal_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: property_defect.scheme.name))
  end
end
