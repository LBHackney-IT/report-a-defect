require 'rails_helper'

RSpec.feature 'Anyone can update a communal_area defect' do
  let(:scheme) { create(:scheme, :with_priorities) }
  let(:communal_area) { create(:communal_area, scheme: scheme) }

  scenario 'a defect can be updated' do
    defect = create(:communal_defect, communal_area: communal_area)
    new_priority = create(:priority, scheme: communal_area.scheme, days: 999)

    visit communal_area_defect_path(defect.communal_area, defect)

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    click_on(I18n.t('generic.link.edit'))

    within('.communal_area_information') do
      expect(page).to have_content(communal_area.name)
      expect(page).to have_content(communal_area.location)
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

    expect(page).to have_content((Date.current + new_priority.days.days).to_date)
  end

  scenario 'any defect status can be chosen' do
    defect = create(:communal_defect, communal_area: communal_area)

    visit edit_communal_area_defect_path(defect.communal_area, defect)

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
    defect = create(:communal_defect, communal_area: communal_area)

    visit communal_area_defect_path(defect.communal_area, defect)

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

  scenario 'updating the priority is optional' do
    defect = create(:communal_defect, communal_area: communal_area)

    visit edit_communal_area_defect_path(defect.communal_area, defect)

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
end
