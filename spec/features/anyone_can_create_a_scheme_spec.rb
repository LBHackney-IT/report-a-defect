require 'rails_helper'

RSpec.feature 'Anyone can create a scheme' do
  scenario 'a scheme can be created' do
    visit root_path

    click_on(I18n.t('scheme.call_to_action'))

    expect(page).to have_content(I18n.t('scheme.new.header'))
    within('form.new_scheme') do
      fill_in 'scheme[name]', with: 'I have a leaky water pipe in
        the bathroom'
      click_on(I18n.t('scheme.submit'))
    end

    expect(page).to have_content(I18n.t('scheme.success.notice'))
    within('table.schemes') do
      expect(page).to have_content(Scheme.first.name)
    end
  end

  scenario 'an invalid scheme cannot be submitted' do
    visit root_path

    click_on(I18n.t('scheme.call_to_action'))

    expect(page).to have_content(I18n.t('scheme.new.header'))
    within('form.new_scheme') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('scheme.submit'))
    end

    within('.scheme_name') do
      expect(page).to have_content("can't be blank")
    end

    within('.error-message-list') do
      expect(page).to have_content("Name can't be blank")
    end
  end
end
