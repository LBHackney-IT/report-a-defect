require 'rails_helper'

RSpec.feature 'Staff can visit the service' do
  scenario 'visit the home page' do
    visit dashboard_path
    expect(page).to have_content(I18n.t('service.name'))
  end
end
