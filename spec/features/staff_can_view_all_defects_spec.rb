require 'rails_helper'

RSpec.feature 'Staff can view all defects' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'all open defects are shown by default' do
    property_defect = DefectPresenter.new(create(:property_defect, status: :outstanding))
    communal_defect = DefectPresenter.new(create(:communal_defect, status: :outstanding))

    visit dashboard_path

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
        href: communal_area_defect_path(communal_defect.communal_area, communal_defect)
      )
    end
  end

  scenario 'closed defects can be shown' do
    _open_defect = DefectPresenter.new(create(:property_defect, status: :outstanding))
    closed_defect = DefectPresenter.new(create(:property_defect, :completed))

    visit dashboard_path

    click_on('View all defects')

    within('.filter-defects') do
      check 'Closed', name: 'statuses[]'
      click_on(I18n.t('generic.button.filter'))
    end

    within '.defects' do
      expect(page).to have_content(closed_defect.reference_number)
      expect(page).to have_content(closed_defect.status)
      expect(page).to have_content(closed_defect.actual_completion_date)
    end
  end

  scenario 'property defects can be hidden' do
    property_defect = DefectPresenter.new(create(:property_defect, status: :outstanding))
    communal_defect = DefectPresenter.new(create(:communal_defect, status: :outstanding))

    visit dashboard_path

    click_on('View all defects')

    within('.filter-defects') do
      uncheck 'Property', name: 'types[]'
      click_on(I18n.t('generic.button.filter'))
    end

    within '.defects' do
      expect(page).not_to have_content(property_defect.reference_number)
      expect(page).to have_content(communal_defect.reference_number)
    end
  end

  scenario 'communal defects can be hidden' do
    property_defect = DefectPresenter.new(create(:property_defect, status: :outstanding))
    communal_defect = DefectPresenter.new(create(:communal_defect, status: :outstanding))

    visit dashboard_path

    click_on('View all defects')

    within('.filter-defects') do
      uncheck 'Communal', name: 'types[]'
      click_on(I18n.t('generic.button.filter'))
    end

    within '.defects' do
      expect(page).to have_content(property_defect.reference_number)
      expect(page).not_to have_content(communal_defect.reference_number)
    end
  end

  scenario 'all results are shown when no filters are provided' do
    open_property_defect = DefectPresenter.new(create(:property_defect, status: :outstanding))
    closed_property_defect = DefectPresenter.new(create(:property_defect, status: :closed))
    open_communal_defect = DefectPresenter.new(create(:communal_defect, status: :outstanding))
    closed_communal_defect = DefectPresenter.new(create(:communal_defect, status: :closed))

    visit dashboard_path

    click_on('View all defects')

    within('.filter-defects') do
      uncheck_all_filters
      click_on(I18n.t('generic.button.filter'))
    end

    within '.defects' do
      expect(page).to have_content(open_property_defect.reference_number)
      expect(page).to have_content(closed_property_defect.reference_number)
      expect(page).to have_content(open_communal_defect.reference_number)
      expect(page).to have_content(closed_communal_defect.reference_number)
    end
  end

  scenario 'property and communal area defects can be filtered by scheme name' do
    interested_scheme = create(:scheme, name: 'Blue')
    distracting_scheme = create(:scheme, name: 'Red')

    property = create(:property, scheme: interested_scheme)
    communal_area = create(:communal_area, scheme: interested_scheme)
    distracting_property = create(:property, scheme: distracting_scheme)
    distracting_communal_area = create(:communal_area, scheme: distracting_scheme)

    interested_property_defect = DefectPresenter.new(
      create(:property_defect, property: property, status: :outstanding)
    )
    interesting_communal_area_defect = DefectPresenter.new(
      create(:communal_defect, communal_area: communal_area, status: :outstanding)
    )
    distracting_property_defect = DefectPresenter.new(
      create(:property_defect, property: distracting_property, status: :outstanding)
    )
    distracting_communal_area_defect = DefectPresenter.new(
      create(:communal_defect, communal_area: distracting_communal_area, status: :outstanding)
    )

    visit dashboard_path

    click_on('View all defects')

    within('.filter-defects') do
      uncheck_all_filters
      check interested_scheme.name, name: 'scheme_ids[]'
      click_on(I18n.t('generic.button.filter'))
    end

    within '.defects' do
      expect(page).to have_content(interested_property_defect.reference_number)
      expect(page).to have_content(interesting_communal_area_defect.reference_number)
      expect(page).not_to have_content(distracting_property_defect.reference_number)
      expect(page).not_to have_content(distracting_communal_area_defect.reference_number)
    end
  end

  def uncheck_all_filters
    all('input[type=checkbox]').each do |checkbox|
      checkbox.click if checkbox.checked?
    end
  end
end
