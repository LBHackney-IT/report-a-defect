require 'rails_helper'

RSpec.feature 'Anyone can create a scheme' do
  let!(:estate) { create(:estate) }

  scenario 'a scheme can be created' do
    visit estate_path(estate)

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: estate.name).titleize)

    click_on(I18n.t('generic.button.create', resource: 'Scheme'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.create').titleize)
    within('form.new_scheme') do
      fill_in 'scheme[name]', with: 'Kings Cresent'
      click_on(I18n.t('generic.button.create', resource: 'Scheme'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'scheme'))
    within('table.schemes') do
      expect(page).to have_content(Scheme.first.name)
    end
  end

  scenario 'an invalid scheme cannot be submitted' do
    visit estate_path(estate)

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: estate.name).titleize)

    click_on(I18n.t('generic.button.create', resource: 'Scheme'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.create').titleize)
    within('form.new_scheme') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Scheme'))
    end

    within('.scheme_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
