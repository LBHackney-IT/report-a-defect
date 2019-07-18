require 'rails_helper'

RSpec.feature 'Anyone can update a scheme' do
  before(:each) do
    stub_authenticated_session
  end

  let!(:scheme) { create(:scheme) }

  scenario 'a scheme can be udpated' do
    scheme = create(:scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    within('.scheme_contractor') do
      expect(page).to have_content(scheme.contractor_name)
      expect(page).to have_content(scheme.contractor_email_address)
    end

    click_on(I18n.t('button.edit.scheme'))

    within('form.edit_scheme') do
      fill_in 'scheme[name]', with: '1'
      fill_in 'scheme[contractor_name]', with: 'A new contractor name'
      fill_in 'scheme[contractor_email_address]', with: 'new@email.com'
      fill_in 'scheme[employer_agent_name]', with: 'Alex'
      fill_in 'scheme[employer_agent_email_address]', with: 'alex@example.com'
      click_on(I18n.t('button.update.scheme'))
    end
  end

  scenario 'an invalid scheme cannot be updated' do
    scheme = create(:scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    click_on(I18n.t('button.edit.scheme'))

    within('form.edit_scheme') do
      fill_in 'scheme[name]', with: ''
      fill_in 'scheme[contractor_name]', with: ''
      fill_in 'scheme[contractor_email_address]', with: ''

      click_on(I18n.t('button.update.scheme'))
    end

    within('.scheme_name') do
      expect(page).to have_content("can't be blank")
    end

    within('.scheme_contractor_name') do
      expect(page).to have_content("can't be blank")
    end

    within('.scheme_contractor_email_address') do
      expect(page).to have_content("can't be blank")
    end
  end
end
