require 'rails_helper'

RSpec.feature 'Staff can create evidence' do
  before(:each) do
    stub_authenticated_session(name: 'Alex')
  end

  before(:each) do
    travel_to Time.zone.parse('2019-05-23')
  end

  after(:each) do
    travel_back
  end

  context 'when the defect is for a property', :carrierwave do
    let!(:property) { create(:property, address: '1 Hackney Street') }
    let!(:defect) { create(:property_defect, property: property) }

    scenario 'evidence can be created' do
      visit property_defect_url(defect.property, defect)

      expect(page).to have_content(I18n.t('button.create.evidence'))

      click_on(I18n.t('button.create.evidence'))

      within('form.new_evidence') do
        fill_in 'evidence[description]', with: 'Example of cracked doorframe'
        attach_file 'evidence[supporting_file]', Rails.root.join('spec', 'fixtures', 'evidence.png')
        click_on(I18n.t('button.create.evidence'))
      end

      expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'evidence'))

      within('.evidence') do
        evidence = Evidence.first
        expect(page).to have_content(evidence.description)
        expect(page).to have_selector(:css, "a[href='#{evidence.supporting_file.url}']")
      end
    end

    scenario 'can use breadcrumbs to navigate' do
      visit new_defect_evidence_url(defect)

      expect(page).to have_link(
        "Back to #{I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number)}",
        href: property_defect_url(property, defect)
      )
    end
  end

  context 'when the defect is for a communal area', :carrierwave do
    let!(:communal_area) { create(:communal_area, name: 'Hackney Street') }
    let!(:defect) { create(:communal_defect, communal_area: communal_area) }

    scenario 'a communal_area can be found and evidence can be created' do
      visit communal_area_defect_url(defect.communal_area, defect)

      expect(page).to have_content(I18n.t('button.create.evidence'))

      click_on(I18n.t('button.create.evidence'))

      within('form.new_evidence') do
        fill_in 'evidence[description]', with: 'Example of cracked doorframe'
        attach_file 'evidence[supporting_file]', Rails.root.join('spec', 'fixtures', 'evidence.png')
        click_on(I18n.t('button.create.evidence'))
      end

      expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'evidence'))

      within('.evidence') do
        evidence = Evidence.first
        expect(page).to have_content(evidence.description)
      end
    end

    scenario 'can use breadcrumbs to navigate' do
      visit new_defect_evidence_url(defect)

      expect(page).to have_link(
        "Back to #{I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number)}",
        href: communal_area_defect_url(communal_area, defect)
      )
    end
  end

  scenario 'an invalid evidence cannot be submitted' do
    property = create(:property, address: '1 Hackney Street')
    defect = create(:property_defect, property: property)

    visit new_defect_evidence_url(defect)

    within('form.new_evidence') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('button.create.evidence'))
    end

    within('.evidence_description') do
      expect(page).to have_content("can't be blank")
    end
  end
end
