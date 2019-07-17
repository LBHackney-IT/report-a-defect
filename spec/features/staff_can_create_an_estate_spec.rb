require 'rails_helper'

RSpec.feature 'Anyone can create a estate' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a estate can be created' do
    visit dashboard_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    click_on(I18n.t('button.create.estate'))

    expect(page).to have_content(I18n.t('page_title.staff.estates.create'))
    within('form.new_estate') do
      fill_in 'estate[name]', with: 'Kings Cresent'
      click_on(I18n.t('button.create.estate'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'estate'))
    within('table.estates') do
      expect(page).to have_content(Estate.first.name)
    end
  end

  scenario 'an invalid estate cannot be submitted' do
    visit dashboard_path

    click_on(I18n.t('button.create.estate'))

    expect(page).to have_content(I18n.t('page_title.staff.estates.create'))
    within('form.new_estate') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.estate'))
    end

    within('.estate_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
