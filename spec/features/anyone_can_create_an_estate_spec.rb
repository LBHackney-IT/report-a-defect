require 'rails_helper'

RSpec.feature 'Anyone can create a estate' do
  scenario 'a estate can be created' do
    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    click_on(I18n.t('generic.button.create', resource: 'Estate'))

    expect(page).to have_content(I18n.t('page_title.staff.estates.create').titleize)
    within('form.new_estate') do
      fill_in 'estate[name]', with: 'Kings Cresent'
      click_on(I18n.t('generic.button.create', resource: 'Estate'))
    end

    expect(page).to have_content(I18n.t('generic.notice.success', resource: 'estate'))
    within('table.estates') do
      expect(page).to have_content(Estate.first.name)
    end
  end

  scenario 'an invalid estate cannot be submitted' do
    visit root_path

    click_on(I18n.t('generic.button.create', resource: 'Estate'))

    expect(page).to have_content(I18n.t('page_title.staff.estates.create').titleize)
    within('form.new_estate') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Estate'))
    end

    within('.estate_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
