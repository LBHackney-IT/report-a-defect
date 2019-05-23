require 'rails_helper'

RSpec.feature 'Anyone can create a priority for a scheme' do
  let!(:scheme) { create(:scheme) }

  scenario 'a scheme priority can be viewed' do
    priority = create(:priority, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name).titleize)

    within('table.priorities') do
      expect(page).to have_content(priority.name)
      expect(page).to have_content(priority.days)
    end
  end

  scenario 'a scheme priority can be created' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name).titleize)

    click_on(I18n.t('generic.button.create', resource: 'Priority'))
    expect(page).to have_content(I18n.t('page_title.staff.priorities.create').titleize)

    within('form.new_priority') do
      fill_in 'priority[name]', with: 'P1'
      fill_in 'priority[days]', with: 1
      click_on(I18n.t('generic.button.create', resource: 'Priority'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'priority'))
    within('table.priorities') do
      priority = Priority.first
      expect(page).to have_content(priority.name)
      expect(page).to have_content(priority.days)
    end
  end

  scenario 'an invalid priority cannot be submitted' do
    visit new_estate_scheme_priority_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.priorities.create').titleize)

    within('form.new_priority') do
      # Deliberately forget to fill out the required name fields
      click_on(I18n.t('generic.button.create', resource: 'Priority'))
    end

    within('.priority_name') do
      expect(page).to have_content("can't be blank")
    end

    within('.priority_days') do
      expect(page).to have_content("can't be blank")
    end
  end
end
