require 'rails_helper'

RSpec.feature 'Anyone can create a priority for a scheme' do
  scenario 'a scheme priority can be viewed' do
    scheme = create(:scheme)
    priority = create(:priority, scheme: scheme)

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('table.schemes') do
      expect(page).to have_content(scheme.name)
      click_on(I18n.t('generic.link.show'))
    end

    within('table.priorities') do
      expect(page).to have_content(priority.name)
      expect(page).to have_content(priority.duration)
    end
  end

  scenario 'a scheme priority can be created' do
    scheme = create(:scheme)

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('table.schemes') do
      expect(page).to have_content(scheme.name)
      click_on(I18n.t('generic.link.show'))
    end

    click_on(I18n.t('generic.button.create', resource: 'Priority'))
    expect(page).to have_content(I18n.t('page_title.staff.priorities.create').titleize)

    within('form.new_priority') do
      fill_in 'priority[name]', with: 'P1'
      fill_in 'priority[duration]', with: '1 day'
      click_on(I18n.t('generic.button.create', resource: 'Priority'))
    end

    expect(page).to have_content(I18n.t('generic.notice.success', resource: 'priority'))
    within('table.priorities') do
      priority = Priority.first
      expect(page).to have_content(priority.name)
      expect(page).to have_content(priority.duration)
    end
  end
end
