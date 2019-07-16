require 'rails_helper'

RSpec.feature 'Anyone can download defect data' do
  scenario 'download all defects' do
    property_defect = DefectPresenter.new(create(:property_defect))
    communal_defect = DefectPresenter.new(create(:communal_defect))

    visit root_path

    click_on(I18n.t('button.report.download_all'))

    header = page.response_headers['Content-Disposition']
    expect(header).to eql('attachment')

    # Headers
    expected_headers = %w[
      reference_number
      created_at
      title
      type
      status
      trade
      category
      priority_name
      priority_duration
      target_completion_date
      estate
      scheme
      property_address
      communal_area_name
      communal_area_location
      description
      access_information
    ]

    expected_headers.each do |expected_header|
      expect(page).to have_content(expected_header)
    end

    # Property defect
    expect(page).to have_content(property_defect.reference_number)
    expect(page).to have_content(property_defect.created_at.to_s)
    expect(page).to have_content(property_defect.title)
    expect(page).to have_content(property_defect.defect_type)
    expect(page).to have_content(property_defect.status)
    expect(page).to have_content(property_defect.trade)
    expect(page).to have_content(property_defect.category)
    expect(page).to have_content(property_defect.priority.name)
    expect(page).to have_content(property_defect.priority.days)
    expect(page).to have_content(property_defect.target_completion_date)
    expect(page).to have_content(property_defect.scheme.estate.name)
    expect(page).to have_content(property_defect.scheme.name)
    expect(page).to have_content(property_defect.property.address)
    expect(page).to have_content(property_defect.description)
    expect(page).to have_content(property_defect.access_information)

    # Communal defect
    expect(page).to have_content(communal_defect.reference_number)
    expect(page).to have_content(communal_defect.created_at.to_s)
    expect(page).to have_content(communal_defect.title)
    expect(page).to have_content(communal_defect.defect_type)
    expect(page).to have_content(communal_defect.status)
    expect(page).to have_content(communal_defect.trade)
    expect(page).to have_content(communal_defect.priority.name)
    expect(page).to have_content(communal_defect.priority.days)
    expect(page).to have_content(communal_defect.target_completion_date)
    expect(page).to have_content(communal_defect.scheme.estate.name)
    expect(page).to have_content(communal_defect.scheme.name)
    expect(page).to have_content(communal_defect.communal_area.name)
    expect(page).to have_content(communal_defect.communal_area.location)
    expect(page).to have_content(communal_defect.description)
    expect(page).to have_content(communal_defect.access_information)
  end
end
