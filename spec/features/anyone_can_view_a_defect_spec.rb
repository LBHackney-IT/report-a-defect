require 'rails_helper'

RSpec.feature 'Anyone can view a defect' do
  scenario 'a defect can be found and viewed' do
    defect = create(:property_defect)

    visit root_path

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

  scenario 'can use breadcrumbs to navigate back to a property' do
    defect = create(:property_defect)

    visit property_defect_path(defect.property, defect)

    expect(page).to have_link("Back to #{defect.property.address}", href: property_path(defect.property))
  end

  scenario 'can use breadcrumbs to navigate back to a block' do
    defect = create(:communal_defect)

    visit block_defect_path(defect.block, defect)

    expect(page).to have_link("Back to #{defect.block.name}", href: block_path(defect.block))
  end

  scenario 'can see comments' do
    defect = create(:property_defect)
    comment = create(:comment, defect: defect)

    visit property_defect_path(defect.property, defect)

    within('.comments') do
      expect(page).to have_content(comment.message)
      expect(page).to have_content(comment.user.name)
      expect(page).to have_content(comment.created_at)
    end
  end

  scenario 'can see events' do
    travel_to Time.zone.parse('2019-05-23')

    defect = create(:property_defect)

    visit property_defect_path(defect.property, defect)

    within('.events') do
      expect(page).to have_content('defect.create 2019-05-23 00:00:00 UTC')
    end

    travel_back
  end
end
