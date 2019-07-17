require 'rails_helper'

RSpec.feature 'Anyone can view a report for a scheme' do
  before(:each) do
    stub_authenticated_session
  end

  let(:scheme) { create(:scheme, created_at: 5.days.ago) }
  let(:priority) { create(:priority, scheme: scheme) }
  let(:property) { create(:property, scheme: scheme) }
  let(:communal_area) { create(:communal_area, scheme: scheme) }

  scenario 'summary information for all defects belonging to the scheme' do
    create_list(:property_defect, 1, property: property, priority: priority)
    create_list(:communal_defect, 2, communal_area: communal_area, priority: priority)

    visit dashboard_path

    within('.scheme-reports') do
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.reports.scheme.show', name: scheme.name))
    expect(page).to have_content("From #{scheme.created_at.to_date} to #{Date.current}")

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

  scenario 'defect information by trade belonging to the scheme' do
    electrical_property_defects = create_list(:property_defect, 1, property: property, trade: 'Electrical')
    electrical_communal_defects = create_list(:communal_defect, 2, communal_area: communal_area, trade: 'Electrical')

    plumbing_property_defects = create_list(:property_defect, 3, property: property, trade: 'Plumbing')
    plumbing_communal_defects = create_list(:communal_defect, 4, communal_area: communal_area, trade: 'Plumbing')

    visit report_scheme_path(scheme)

    within('.trades') do
      %w[Name Percentage Total].each do |header|
        expect(page).to have_content(header)
      end

      Defect::CATEGORIES.each do |category, _trades|
        expect(page).to have_content(category)
      end

      expect(page).to have_content('30.0%')
      expect(page).to have_content(electrical_property_defects.count + electrical_communal_defects.count)

      expect(page).to have_content('70.0%')
      expect(page).to have_content(plumbing_property_defects.count + plumbing_communal_defects.count)
    end
  end

  scenario 'defect information by scheme priority' do
    travel_to Time.zone.parse('2019-05-23')

    _due_priority = create(:property_defect,
                           property: property,
                           priority: priority,
                           target_completion_date: Date.new(2019, 5, 24))
    _overdue_priorities = create_list(:property_defect,
                                      2,
                                      property: property,
                                      priority: priority,
                                      target_completion_date: Date.new(2019, 5, 22))

    visit report_scheme_path(scheme)

    within('.priorities') do
      %w[Code Days Total Due Overdue Completed on time].each do |header|
        expect(page).to have_content(header)
      end

      scheme.priorities.each do |priority|
        expect(page).to have_content(priority.name)
        expect(page).to have_content(priority.days)
      end

      expect(page).to have_content('100.0%')
      expect(page).to have_content('1')
      expect(page).to have_content('2')
      expect(page).to have_content('3')
    end

    travel_back
  end

  scenario 'defects completed on or before their target date' do
    travel_to Time.zone.parse('2019-05-23')

    completed_early_defect = create(:property_defect,
                                    property: property,
                                    priority: priority,
                                    target_completion_date: Date.new(2019, 5, 22))
    completed_on_time_defect = create(:property_defect,
                                      property: property,
                                      priority: priority,
                                      target_completion_date: Date.new(2019, 5, 23))
    completed_later_defect = create(:property_defect,
                                    property: property,
                                    priority: priority,
                                    target_completion_date: Date.new(2019, 5, 24))

    # Update the records status so that PublicActivity creates the required defect.update events
    [
      completed_early_defect,
      completed_on_time_defect,
      completed_later_defect,
    ].each(&:completed!)

    visit report_scheme_path(scheme)

    within('.priorities') do
      expect(page).to have_content('2')
    end

    travel_back
  end

  scenario 'filter defects' do
    travel_to Time.zone.parse('2019-05-25')

    defect_one = create(:property_defect, created_at: Time.utc(2019, 5, 23), property: property)
    defect_two = create(:property_defect, created_at: Time.utc(2019, 5, 24), property: property)
    defect_three = create(:communal_defect, created_at: Time.utc(2019, 5, 24), communal_area: communal_area)
    defect_four = create(:property_defect, created_at: Time.utc(2019, 5, 25), property: property)

    defects = [defect_one, defect_two, defect_three, defect_four]

    visit report_scheme_path(scheme)

    within('.summary') do
      expect(page).to have_content(defects.count)
    end

    within('.date-filter') do
      fill_in 'from_day', with: '5'
      fill_in 'from_month', with: '23'
      fill_in 'from_year', with: '2019'
      fill_in 'to_day', with: '24'
      fill_in 'to_month', with: '5'
      fill_in 'to_year', with: '2019'
    end

    within('.summary') do
      expect(page).to have_content('3')
    end

    travel_back
  end
end