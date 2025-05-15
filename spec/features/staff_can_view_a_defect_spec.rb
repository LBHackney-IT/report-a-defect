require 'rails_helper'

RSpec.feature 'Staff can view a defect' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'a defect can be found and viewed' do
    defect = create(:property_defect)

    visit dashboard_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: defect.property.address
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    within('.defects') do
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    expect(page).to have_content(defect.reference_number)
    expect(page).to have_content(defect.title)

    within('.summary') do
      expect(page).to have_content(defect.priority.name)
      expect(page).to have_content(defect.status)
      expect(page).to have_content(defect.target_completion_date)
      expect(page).to have_content(defect.trade)
    end

    within('.description') do
      expect(page).to have_content(defect.description)
    end

    within('.property-location') do
      expect(page).to have_content(defect.property.address)
      expect(page).to have_content(defect.property.postcode)
    end

    within('.contact-information') do
      expect(page).to have_content(defect.contact_name)
      expect(page).to have_content(defect.contact_phone_number)
      expect(page).to have_content(defect.contact_email_address)
    end
  end

  scenario 'a property defect can be found by reference number' do
    defect = create(:property_defect)

    visit dashboard_path

    within('form.search') do
      fill_in 'query', with: defect.reference_number
      click_on(I18n.t('generic.button.find'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    expect(page).to have_content(defect.reference_number)
    expect(page).to have_content(defect.title)
  end

  scenario 'a communal defect can be found by reference number' do
    defect = create(:communal_defect)

    visit dashboard_path

    within('form.search') do
      fill_in 'query', with: defect.reference_number
      click_on(I18n.t('generic.button.find'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    expect(page).to have_content(defect.reference_number)
    expect(page).to have_content(defect.title)
  end

  scenario 'a defect can be found by reformatted reference number' do
    defect = create(:property_defect)

    visit dashboard_path

    within('form.search') do
      fill_in 'query', with: defect.reference_number.gsub('-', '')
      click_on(I18n.t('generic.button.find'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))

    expect(page).to have_content(defect.reference_number)
    expect(page).to have_content(defect.title)
  end

  scenario 'entering an unknown reference number' do
    visit dashboard_path

    reference_number = ReferenceNumber.new(0)

    within('form.search') do
      fill_in 'query', with: reference_number.to_s
      click_on(I18n.t('generic.button.find'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))
    expect(page).to have_content(I18n.t('page_content.defect.not_found', reference_number: reference_number.to_s))
  end

  scenario 'can use breadcrumbs to navigate back to a property' do
    defect = create(:property_defect)

    visit property_defect_path(defect.property, defect)

    expect(page).to have_link(defect.property.address, href: property_path(defect.property))
  end

  scenario 'can use breadcrumbs to navigate back to a communal_area' do
    defect = create(:communal_defect)

    visit communal_area_defect_path(defect.communal_area, defect)

    expect(page).to have_link(defect.communal_area.name, href: communal_area_path(defect.communal_area))
  end

  scenario 'can see comments' do
    travel_to Time.zone.parse('2019-05-23')

    defect = create(:property_defect)
    comment = create(:comment, defect: defect)

    visit property_defect_path(defect.property, defect)

    within('.comments') do
      expect(page).to have_content("Comment left by #{comment.user.name} posted on 23 May 2019 at 00:00")
      expect(page).to have_content(comment.message)
    end

    travel_back
  end

  scenario 'can see events' do
    travel_to Time.zone.parse('2019-05-23')

    defect = create(:property_defect)

    visit property_defect_path(defect.property, defect)

    within('.events') do
      expect(page).to have_content('defect.create on 23 May 2019 at 00:00')
    end

    travel_back
  end
end
