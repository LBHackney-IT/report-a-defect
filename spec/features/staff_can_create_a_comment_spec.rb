require 'rails_helper'

RSpec.feature 'Staff can create a comment' do
  before(:each) do
    stub_authenticated_session(name: 'Alex')
  end

  before(:each) do
    travel_to Time.zone.parse('2019-05-23')
  end

  after(:each) do
    travel_back
  end

  context 'when the defect is for a property' do
    let!(:property) { create(:property, address: '1 Hackney Street') }
    let!(:defect) { create(:property_defect, property: property) }

    scenario 'a property can be found and comment can be created' do
      visit dashboard_path

      expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

      within('form.search') do
        fill_in 'query', with: 'Hackney'
        click_on(I18n.t('generic.button.find'))
      end

      within('.properties') do
        click_on(I18n.t('generic.link.show'))
      end

      expect(page).to have_content(I18n.t('page_title.staff.properties.show', name: property.address))

      within('.defects') do
        click_on(I18n.t('generic.link.show'))
      end

      expect(page).to have_content(I18n.t('button.create.comment'))

      click_on(I18n.t('button.create.comment'))

      within('form.new_comment') do
        fill_in 'comment[message]', with: 'None of the electrics work'
        click_on(I18n.t('button.create.comment'))
      end

      expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'comment'))

      within('.comments') do
        comment = Comment.first
        expect(page).to have_content('Comment left by Alex posted on 23 May 2019 at 00:00')
        expect(page).to have_content(comment.message)
      end
    end

    scenario 'can use breadcrumbs to navigate' do
      visit new_defect_comment_path(defect)

      expect(page).to have_link(
        "Back to #{I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number)}",
        href: property_defect_path(property, defect)
      )
    end
  end

  context 'when the defect is for a communal area' do
    let!(:communal_area) { create(:communal_area, name: 'Hackney Street') }
    let!(:defect) { create(:communal_defect, communal_area: communal_area) }

    scenario 'a communal_area can be found and comment can be created' do
      visit dashboard_path

      expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

      within('form.search') do
        fill_in 'query', with: 'Hackney'
        click_on(I18n.t('generic.button.find'))
      end

      within('.communal_areas') do
        click_on(I18n.t('generic.link.show'))
      end

      expect(page).to have_content(I18n.t('page_title.staff.communal_areas.show', name: communal_area.name))

      within('.defects') do
        click_on(I18n.t('generic.link.show'))
      end

      click_on(I18n.t('button.create.comment'))

      within('form.new_comment') do
        fill_in 'comment[message]', with: 'None of the electrics work'
        click_on(I18n.t('button.create.comment'))
      end

      expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'comment'))

      within('.comments') do
        comment = Comment.first
        expect(page).to have_content('Comment left by Alex posted on 23 May 2019 at 00:00')
        expect(page).to have_content(comment.message)
      end
    end

    scenario 'can use breadcrumbs to navigate' do
      visit new_defect_comment_path(defect)

      expect(page).to have_link(
        "Back to #{I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number)}",
        href: communal_area_defect_path(communal_area, defect)
      )
    end
  end

  scenario 'an invalid comment cannot be submitted' do
    property = create(:property, address: '1 Hackney Street')
    defect = create(:property_defect, property: property)

    visit new_defect_comment_path(defect)

    expect(page).to have_content(I18n.t('page_title.staff.comments.create'))
    within('form.new_comment') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.comment'))
    end

    within('.comment_message') do
      expect(page).to have_content("can't be blank")
    end
  end
end
