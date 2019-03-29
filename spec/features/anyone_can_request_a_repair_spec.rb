require 'rails_helper'

RSpec.feature 'Anyone can request a repair' do
  scenario 'a repair can be requested' do
    visit root_path

    click_on(I18n.t('repair.call_to_action'))

    expect(page).to have_content(I18n.t('repair.new.header'))
    within('form.new_repair') do
      fill_in 'repair[description]', with: 'I have a leaky water pipe in
        the bathroom'
      click_on(I18n.t('repair.submit'))
    end

    expect(page).to have_content('We have successfully received your repair,
        expect a reply within 4 hours.')
  end

  scenario 'an invalid repair cannot be submitted' do
    visit root_path

    click_on(I18n.t('repair.call_to_action'))

    expect(page).to have_content(I18n.t('repair.new.header'))
    within('form.new_repair') do
      # Deliberately forget to fill out the required description field
      click_on(I18n.t('repair.submit'))
    end

    expect(page).to have_content("Description can't be blank")
  end
end
