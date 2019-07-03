require 'rails_helper'

RSpec.feature 'Anyone can view all defects' do
  scenario 'open defects are shown by default' do
    property_defect = DefectPresenter.new(create(:property_defect, status: :outstanding))
    communal_defect = DefectPresenter.new(create(:communal_defect, status: :outstanding))

    visit root_path

    click_on('View all defects')

    within('.defects') do
      expect(page).to have_content(property_defect.reference_number)
      expect(page).to have_content(property_defect.title)
      expect(page).to have_content(property_defect.scheme.name)
      expect(page).to have_content(property_defect.defect_type)
      expect(page).to have_content(property_defect.status)
      expect(page).to have_content(property_defect.address)
      expect(page).to have_content(property_defect.priority.name)
      expect(page).to have_content(property_defect.trade)
      expect(page).to have_content(property_defect.target_completion_date)
      expect(page).to have_link(
        I18n.t('generic.link.show'),
        href: property_defect_path(property_defect.property, property_defect)
      )
      expect(page).to have_content(communal_defect.reference_number)
      expect(page).to have_content(communal_defect.title)
      expect(page).to have_content(property_defect.scheme.name)
      expect(page).to have_content(communal_defect.defect_type)
      expect(page).to have_content(communal_defect.status)
      expect(page).to have_content(communal_defect.address)
      expect(page).to have_content(communal_defect.priority.name)
      expect(page).to have_content(communal_defect.trade)
      expect(page).to have_content(communal_defect.target_completion_date)
      expect(page).to have_link(
        I18n.t('generic.link.show'),
        href: communal_area_defect_path(communal_defect.communal_area, communal_defect)
      )
    end
  end
end
