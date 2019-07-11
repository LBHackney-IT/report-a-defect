require 'rails_helper'

RSpec.feature 'Anyone can view a report for a scheme' do
  scenario 'summary information for all defects belonging to the scheme' do
    scheme = create(:scheme)
    priority = create(:priority, scheme: scheme)
    property = create(:property, scheme: scheme)
    communal_area = create(:communal_area, scheme: scheme)

    create_list(:property_defect, 1, property: property, priority: priority)
    create_list(:communal_defect, 2, communal_area: communal_area, priority: priority)

    visit root_path

    within('.scheme-reports') do
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.reports.scheme.show', name: scheme.name))

    within('.summary') do
      %w[Title Property Communal Total].each do |column_header|
        expect(page).to have_content(column_header)
      end
      within('tbody tr') do
        expect(page).to have_content('Total defects')
        expect(page).to have_content('1')
        expect(page).to have_content('2')
        expect(page).to have_content('3')
      end
    end
  end
end
