require 'rails_helper'

RSpec.feature 'Staff can create a defect for a communal_area' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a communal_area can be found and defect can be created' do
    communal_area = create(:communal_area, name: 'Chipping')
    priority = create(:priority, scheme: communal_area.scheme, name: 'P1', days: 1)

    visit dashboard_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Chipping'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.communal_areas.show', name: communal_area.name))

    click_on(I18n.t('button.create.communal_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create.communal_area'))

    within('.communal_area_information') do
      expect(page).to have_content(communal_area.name)
      expect(page).to have_content(communal_area.location)
    end

    within('form.new_defect') do
      fill_in 'created_at[day]', with: '1'
      fill_in 'created_at[month]', with: '2'
      fill_in 'created_at[year]', with: '2019'
      fill_in 'defect[title]', with: 'Electrics failed'
      fill_in 'defect[access_information]', with: '33-50 Hackney Street, communal entrance'
      fill_in 'defect[description]', with: 'None of the electrics work'
      fill_in 'defect[contact_name]', with: 'Alex Stone'
      fill_in 'defect[contact_email_address]', with: 'email@example.com'
      fill_in 'defect[contact_phone_number]', with: '07123456789'
      select 'Electrical', from: 'defect[trade]'
      choose priority.name
      click_on(I18n.t('button.create.communal_defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'defect'))
    within('table.defects') do
      defect = communal_area.reload.defects.first

      expect(page).to have_content('Electrics failed')
      expect(page).to have_content('Electrical')
      expect(page).to have_content('Outstanding')
      expect(page).to have_content(priority.name)
      expect(page).to have_content('1 February 2019')
      expect(page).to have_content(defect.target_completion_date)
      expect(page).to have_content(defect.reference_number)
    end

    click_on(I18n.t('generic.link.show'))

    within('.communal-location') do
      expect(page).to have_content('Communal Area')
      expect(page).to have_content('33-50 Hackney Street, communal entrance')
    end
  end

  scenario 'an invalid defect cannot be submitted' do
    communal_area = create(:communal_area)

    visit communal_area_path(communal_area)

    click_on(I18n.t('button.create.communal_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create.communal_area'))
    within('form.new_defect') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.communal_defect'))
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

  scenario 'a property defect can be created after finishing the creation of a communal defect' do
    communal_defect = create(:communal_defect)

    # Skip a manual defect creation when it's not the part under test
    visit communal_area_path(communal_defect.communal_area)

    expect(page).to have_link(
      I18n.t('button.create.property_defect'),
      href: estate_scheme_path(communal_defect.scheme.estate, communal_defect.scheme, anchor: 'properties')
    )
    click_on(I18n.t('button.create.property_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: communal_defect.scheme.name))
  end

  scenario 'any status can be given' do
    communal_area = create(:communal_area)

    visit communal_area_path(communal_area)

    click_on(I18n.t('button.create.communal_defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create.communal_area'))

    expected_statues = %w[outstanding completed closed raised_in_error follow_on end_of_year referral rejected dispute]

    within('form.new_defect') do
      expected_statues.each do |status|
        select status.capitalize.tr('_', ' '), from: 'defect[status]'
      end
      click_on(I18n.t('button.create.communal_defect'))
    end
  end
end
