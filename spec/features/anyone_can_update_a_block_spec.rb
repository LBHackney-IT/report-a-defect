require 'rails_helper'

RSpec.feature 'Anyone can update a block' do
  let!(:scheme) { create(:scheme) }

  scenario 'a block can be udpated' do
    create(:block, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.blocks') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_block') do
      fill_in 'block[name]', with: 'Darling'
      click_on(I18n.t('generic.button.update', resource: 'Block'))
    end
  end

  scenario 'an invalid block cannot be updated' do
    create(:block, scheme: scheme)

    visit estate_scheme_path(scheme.estate, scheme)

    expect(page).to have_content(I18n.t('page_title.staff.schemes.show', name: scheme.name))

    within('table.blocks') do
      click_on(I18n.t('generic.link.edit'))
    end

    within('form.edit_block') do
      fill_in 'block[name]', with: ''

      click_on(I18n.t('generic.button.update', resource: 'Block'))
    end

    within('.block_name') do
      expect(page).to have_content("can't be blank")
    end
  end
end
