require 'rails_helper'

RSpec.feature 'Staff can create a scheme' do
  before(:each) do
    stub_authenticated_session
  end

  let!(:estate) { create(:estate) }

  scenario 'a scheme can be created' do
    visit estate_path(estate)

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: estate.name))

    click_on(I18n.t('button.create.scheme'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.create'))
    within('form.new_scheme') do
      fill_in 'scheme[name]', with: 'Kings Cresent'
      fill_in 'scheme[contractor_name]', with: 'Builders R Us'
      fill_in 'scheme[contractor_email_address]', with: 'email@example.com'
      fill_in 'scheme[employer_agent_name]', with: 'Alex'
      fill_in 'scheme[employer_agent_email_address]', with: 'alex@example.com'
      fill_in 'scheme[employer_agent_phone_number]', with: '07712345678'
      fill_in 'scheme[project_manager_name]', with: 'Sara'
      fill_in 'scheme[project_manager_email_address]', with: 'sara@example.com'
      fill_in 'start_date[day]', with: '1'
      fill_in 'start_date[month]', with: '2'
      fill_in 'start_date[year]', with: '2019'
      click_on(I18n.t('button.create.scheme'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'scheme'))

    scheme = Scheme.first

    within('table.schemes') do
      expect(page).to have_content(scheme.name)
      expect(page).to have_content(scheme.contractor_name)
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content('1 February 2019')
    expect(page).to have_content(scheme.contractor_email_address)
    expect(page).to have_content(scheme.employer_agent_name)
    expect(page).to have_content(scheme.employer_agent_email_address)
    expect(page).to have_content(scheme.employer_agent_phone_number)
    expect(page).to have_content(scheme.project_manager_name)
    expect(page).to have_content(scheme.project_manager_email_address)
  end

  scenario 'an invalid scheme cannot be submitted' do
    visit estate_path(estate)

    expect(page).to have_content(I18n.t('page_title.staff.estates.show', name: estate.name))

    click_on(I18n.t('button.create.scheme'))

    expect(page).to have_content(I18n.t('page_title.staff.schemes.create'))
    within('form.new_scheme') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.scheme'))
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
