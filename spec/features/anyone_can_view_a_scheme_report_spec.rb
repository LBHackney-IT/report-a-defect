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
    expect(page).to have_content("From #{scheme.created_at} to #{Time.current}")

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

  scenario 'defect information by status belonging to the scheme' do
    outstanding_property_defects = create_list(:property_defect, 1, property: property, status: :outstanding)
    outstanding_communal_defects = create_list(:communal_defect, 2, communal_area: communal_area, status: :outstanding)

    closed_property_defects = create_list(:property_defect, 3, property: property, status: :closed)
    closed_communal_defects = create_list(:communal_defect, 4, communal_area: communal_area, status: :closed)

    visit report_scheme_path(scheme)

    within('.statuses') do
      %w[Name Property Communal Total].each do |header|
        expect(page).to have_content(header)
      end

      Defect.statuses.each do |text, _integer|
        expect(page).to have_content(format_status(text))
      end

      expect(page).to have_content(outstanding_property_defects.count)
      expect(page).to have_content(outstanding_communal_defects.count)
      expect(page).to have_content(outstanding_property_defects.count + outstanding_communal_defects.count)

      expect(page).to have_content(closed_property_defects.count)
      expect(page).to have_content(closed_communal_defects.count)
      expect(page).to have_content(closed_property_defects.count + closed_communal_defects.count)
    end
  end
end
