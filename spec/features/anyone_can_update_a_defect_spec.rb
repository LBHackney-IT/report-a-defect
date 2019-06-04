require 'rails_helper'

RSpec.feature 'Anyone can update a defect' do
  let!(:scheme) { create(:scheme) }

  scenario 'a defect can be updated' do
    defect = create(:defect)

    visit defect_path(defect)

    expect(page).to have_content(I18n.t('page_title.staff.defects.show', name: defect))

    within('table.properties') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_defect') do
      fill_in 'defect[core_name]', with: 'A name for a collection of blocks'
      click_on(I18n.t('generic.button.update', resource: 'Property'))
    end
    expect(page).to have_content((Time.zone.now + priority.days.days).to_date)
  end

  scenario 'an invalid defect cannot be updated' do
    create(:defect, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.properties') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_defect') do
      fill_in 'defect[core_name]', with: ''

      click_on(I18n.t('generic.button.update', resource: 'Property'))
    end

    within('.defect_core_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
