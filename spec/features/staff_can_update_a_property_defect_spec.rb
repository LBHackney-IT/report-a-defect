require 'rails_helper'

RSpec.feature 'Staff can update a defect' do
  before(:each) do
    stub_authenticated_session
  end

  let(:scheme) { create(:scheme, :with_priorities) }
  let(:property) { create(:property, scheme: scheme) }
  let!(:defect) { create(:communal_defect, property: property) }

  scenario 'a defect can be updated' do
    new_priority = create(:priority, scheme: property.scheme, days: 999)

    visit property_defect_path(defect.property, defect)

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    click_on(I18n.t('generic.link.edit'))

    within('.property_information') do
      expect(page).to have_content(property.uprn)
      expect(page).to have_content(property.address)
      expect(page).to have_content(property.postcode)
    end

    within('form.edit_defect') do
      fill_in 'defect[title]', with: 'New title'
      fill_in 'defect[description]', with: 'New description'
      fill_in 'defect[contact_name]', with: 'New name'
      fill_in 'defect[contact_email_address]', with: 'email@foo.com'
      fill_in 'defect[contact_phone_number]', with: '0123456789'
      select 'Brickwork', from: 'defect[trade]'

      expect(page).to have_content(defect.target_completion_date)

      choose "#{new_priority.name} - #{new_priority.days} days from now"
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))

    expect(page).to have_content('New title')
    expect(page).to have_content('New description')
    expect(page).to have_content('New name')
    expect(page).to have_content('email@foo.com')
    expect(page).to have_content('0123456789')
    expect(page).to have_content('Brickwork')
    expect(page).to have_content(new_priority.name)

    expect(page).to have_content((Date.current + new_priority.days).to_date)
  end

  scenario 'a defect status can be updated' do
    visit edit_property_defect_path(defect.property, defect)

    within('form.edit_defect') do
      select 'Closed', from: 'defect[status]'
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
    expect(page).to have_content('Closed')
  end

  scenario 'a detect status change is listed as an event' do
    stub_authenticated_session(name: 'Bob')

    travel_to Time.zone.parse('2019-05-23')

    defect = create(:property_defect, property: property, status: :outstanding)

    visit edit_property_defect_path(defect.property, defect)

    within('form.edit_defect') do
      select 'Closed', from: 'defect[status]'
      click_on(I18n.t('button.update.defect'))
    end

    within('.events') do
      expect(page).to have_content(
        I18n.t('events.defect.status_changed', name: 'Bob', old: 'Outstanding', new: 'Closed')
      )
    end
  end

  scenario 'any defect status can be chosen' do
    visit edit_property_defect_path(defect.property, defect)

    expected_statues = %w[outstanding completed closed raised_in_error follow_on end_of_year referral rejected dispute]

    within('form.edit_defect') do
      expected_statues.each do |status|
        select status.capitalize.tr('_', ' '), from: 'defect[status]'
      end
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
    expect(page).to have_content(expected_statues.last.capitalize)
  end

  scenario 'an invalid defect cannot be updated' do
    visit property_defect_path(defect.property, defect)

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    click_on(I18n.t('generic.link.edit'))

    within('form.edit_defect') do
      fill_in 'defect[description]', with: ''
      select '', from: 'defect[trade]'

      click_on(I18n.t('button.update.defect'))
    end

    within('.defect_description') do
      expect(page).to have_content("can't be blank")
    end

    within('.defect_trade') do
      expect(page).to have_content("can't be blank")
    end
  end

  scenario 'setting the target completion date' do
    visit edit_property_defect_path(defect.communal_area, defect)

    within('form.edit_defect') do
      fill_in 'target_completion_date_day', with: '31'
      fill_in 'target_completion_date_month', with: '7'
      fill_in 'target_completion_date_year', with: '2020'
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
    expect(page).to have_content('31 July 2020')
  end

  scenario 'updating the priority is optional' do
    visit edit_property_defect_path(defect.property, defect)

    within('.existing-priority-information') do
      expect(page).to have_content('Priority status')
      expect(page).to have_content(defect.priority.name)
      expect(page).to have_content('Target date for completion')
      expect(page).to have_content(defect.target_completion_date)
    end

    within('form.edit_defect') do
      # Do not choose a new priority
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
  end

  scenario 'completing a defect and providing the actual completion date' do
    defect = create(:property_defect, property: property, status: :outstanding)

    visit edit_property_defect_path(defect.property, defect)

    expect(NotifyDefectCompletedJob).to receive(:perform_later).with(defect.id)

    within('form.edit_defect') do
      select 'Completed', from: 'defect[status]'
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.defects.completion.new', reference_number: defect.reference_number))

    within('form.edit_defect') do
      fill_in 'actual_completion_date_day', with: '28'
      fill_in 'actual_completion_date_month', with: '7'
      fill_in 'actual_completion_date_year', with: '2020'
      click_on(I18n.t('button.complete.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
    expect(page).to have_content('28 July 2020')
  end

  scenario 'adding an actual completion date after completion' do
    defect = create(:property_defect, :completed, property: property, actual_completion_date: nil)

    visit edit_property_defect_path(defect.property, defect)

    within('form.edit_defect') do
      fill_in 'actual_completion_date_day', with: '29'
      fill_in 'actual_completion_date_month', with: '7'
      fill_in 'actual_completion_date_year', with: '2020'
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
    expect(page).to have_content('29 July 2020')
  end

  scenario 'updating the actual completion date' do
    defect = create(:property_defect, :completed, property: property)

    visit edit_property_defect_path(defect.property, defect)

    within('form.edit_defect') do
      fill_in 'actual_completion_date_day', with: '29'
      fill_in 'actual_completion_date_month', with: '7'
      fill_in 'actual_completion_date_year', with: '2020'
      click_on(I18n.t('button.update.defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'defect'))
    expect(page).to have_content('29 July 2020')
  end

  scenario 'attempting to update the actual completion date before completion' do
    defect = create(:property_defect, property: property, status: :outstanding)

    visit edit_property_defect_path(defect.property, defect)

    within('form.edit_defect') do
      expect(page).to_not have_field 'actual_completion_date[day]'
      expect(page).to_not have_field 'actual_completion_date[month]'
      expect(page).to_not have_field 'actual_completion_date[year]'
    end
  end
end
