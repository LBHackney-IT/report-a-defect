require 'rails_helper'

RSpec.feature 'Staff can forward defect information by email' do
  before(:each) do
    stub_authenticated_session
  end

  let(:scheme) { create(:scheme, :with_priorities) }

  context 'when the defect is a property defect' do
    let(:property) { create(:property, scheme: scheme) }
    scenario 'a defect can be forwarded to the contractor' do
      defect = create(:property_defect, property: property)

      visit property_defect_path(defect.property, defect)

      expect(page).not_to have_content('An email was sent to the contractor')

      click_on(I18n.t('button.forward.contractor'))

      expect(page).to have_content(I18n.t('page_title.staff.defects.forwarding.create', recipient_type: 'contractor'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.new.contractor'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.unsent', recipient_type: 'contractor'))

      expect_any_instance_of(EmailContractor).to receive(:call)

      click_on(I18n.t('generic.button.send'))

      expect(page).to have_content(I18n.t('page_content.defect.forwarding.success', recipient_type: 'contractor'))
      expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))
    end

    scenario 'a defect can be forwarded to the employer agent' do
      defect = create(:property_defect, property: property)

      visit property_defect_path(defect.property, defect)

      expect(page).not_to have_content('An email was sent to the employer agent')

      click_on(I18n.t('button.forward.employer_agent'))

      expect(page).to have_content(I18n.t('page_title.staff.defects.forwarding.create', recipient_type: 'employer agent'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.new.employer agent'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.unsent', recipient_type: 'employer agent'))

      expect_any_instance_of(EmailEmployerAgent).to receive(:call)

      click_on(I18n.t('generic.button.send'))

      expect(page).to have_content(I18n.t('page_content.defect.forwarding.success', recipient_type: 'employer agent'))
      expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))
    end
  end

  context 'when the defect is a communal defect' do
    let(:communal_area) { create(:communal_area, scheme: scheme) }
    scenario 'a defect can be forwarded to the contractor' do
      defect = create(:communal_defect, communal_area: communal_area)

      visit communal_area_defect_path(defect.communal_area, defect)

      expect(page).not_to have_content('An email was sent to the contractor')

      click_on(I18n.t('button.forward.contractor'))

      expect(page).to have_content(I18n.t('page_title.staff.defects.forwarding.create', recipient_type: 'contractor'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.new.contractor'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.unsent', recipient_type: 'contractor'))

      expect_any_instance_of(EmailContractor).to receive(:call)

      click_on(I18n.t('generic.button.send'))

      expect(page).to have_content(I18n.t('page_content.defect.forwarding.success', recipient_type: 'contractor'))
      expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))
    end

    scenario 'a defect can be forwarded to the employer agent' do
      defect = create(:communal_defect, communal_area: communal_area)

      visit communal_area_defect_path(defect.communal_area, defect)

      expect(page).not_to have_content('An email was sent to the employer agent')

      click_on(I18n.t('button.forward.employer_agent'))

      expect(page).to have_content(I18n.t('page_title.staff.defects.forwarding.create', recipient_type: 'employer agent'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.new.employer agent'))
      expect(page).to have_content(I18n.t('page_content.defect.forwarding.unsent', recipient_type: 'employer agent'))

      expect_any_instance_of(EmailEmployerAgent).to receive(:call)

      click_on(I18n.t('generic.button.send'))

      expect(page).to have_content(I18n.t('page_content.defect.forwarding.success', recipient_type: 'employer agent'))
      expect(page).to have_content(I18n.t('page_title.staff.defects.show', reference_number: defect.reference_number))
    end
  end

  scenario 'forwarding to a contractor' do
    communal_area = create(:communal_area, scheme: scheme)
    defect = create(:communal_defect, communal_area: communal_area)

    visit communal_area_defect_path(defect.communal_area, defect)

    click_on(I18n.t('button.forward.contractor'))

    expect(page).to have_content(I18n.t('page_content.defect.forwarding.new.contractor'))
  end
end
