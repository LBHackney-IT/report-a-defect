require 'rails_helper'

RSpec.feature 'Anyone can create a block' do
  let!(:scheme) { create(:scheme) }

  scenario 'a block can be created' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('generic.button.create', resource: 'Block'))

    expect(page).to have_content(I18n.t('page_title.staff.blocks.create'))
    within('form.new_block') do
      fill_in 'block[name]', with: 'Chipping'
      click_on(I18n.t('generic.button.create', resource: 'Block'))
    end

    expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'block'))
    within('table.blocks') do
      expect(page).to have_content('Chipping')
    end
  end

  scenario 'an invalid block cannot be submitted' do
    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    click_on(I18n.t('generic.button.create', resource: 'Block'))

    expect(page).to have_content(I18n.t('page_title.staff.blocks.create'))
    within('form.new_block') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Block'))
    end

    within('.block_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
