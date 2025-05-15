RSpec.feature 'Users can sign in with auth0' do
  scenario 'successful sign in' do
    mock_successful_authentication

    visit dashboard_path

    expect(page).to have_content(I18n.t('page_title.welcome'))

    click_on(I18n.t('generic.button.sign_in'))

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    expect(page).to have_link(I18n.t('generic.link.sign_out'), href: sign_out_path)
  end

  scenario 'protected pages cannot be visited unless signed in' do
    visit dashboard_path
    expect(page).to have_content(I18n.t('page_title.welcome'))

    visit defects_path
    expect(page).to have_content(I18n.t('page_title.welcome'))
  end
end
