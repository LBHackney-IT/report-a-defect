require 'rails_helper'

RSpec.feature 'Anyone can create a defect for a block' do
  scenario 'a block can be found and defect can be created' do
    block = create(:block, name: 'Chipping')
    priority = create(:priority, scheme: block.scheme, name: 'P1', days: 1)

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Chipping'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.blocks.show', name: block.name))

    click_on(I18n.t('generic.button.create', resource: 'Defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create'))

    within('.block_information') do
      expect(page).to have_content(block.name)
    end

    within('form.new_defect') do
      fill_in 'defect[title]', with: 'Electrics failed'
      fill_in 'defect[access_information]', with: '33-50 Hackney Street, communal entrance'
      fill_in 'defect[description]', with: 'None of the electrics work'
      fill_in 'defect[contact_name]', with: 'Alex Stone'
      fill_in 'defect[contact_email_address]', with: 'email@example.com'
      fill_in 'defect[contact_phone_number]', with: '07123456789'
      select 'Electrical', from: 'defect[trade]'
      choose priority.name
      click_on(I18n.t('generic.button.create', resource: 'Defect'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'defect'))
    within('table.defects') do
      defect = block.reload.defects.first

      expect(page).to have_content('Electrics failed')
      expect(page).to have_content('Electrical')
      expect(page).to have_content('Outstanding')
      expect(page).to have_content(priority.name)
      expect(page).to have_content(defect.target_completion_date)
      expect(page).to have_content(defect.reference_number)
    end

    click_on(I18n.t('generic.link.show'))

    within('.defect_information') do
      expect(page).to have_content('33-50 Hackney Street, communal entrance')
    end
  end

  scenario 'an invalid defect cannot be submitted' do
    block = create(:block)

    visit block_path(block)

    click_on(I18n.t('generic.button.create', resource: 'Defect'))

    expect(page).to have_content(I18n.t('page_title.staff.defects.create'))
    within('form.new_defect') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Defect'))
    end

    within('.defect_description') do
      expect(page).to have_content("can't be blank")
    end

    within('.defect_trade') do
      expect(page).to have_content("can't be blank")
    end

    within('.defect_priority') do
      expect(page).to have_content("can't be blank")
    end
  end
end
