require 'rails_helper'

RSpec.feature 'Anyone can find a block' do
  scenario 'with a name' do
    scheme = create(:scheme)
    interested_block = create(:block, scheme: scheme, name: 'Clift House')
    uninterested_block = create(:block, scheme: scheme, name: 'Darling House')

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Clift'
      click_on(I18n.t('generic.button.find'))
    end

    within('table.blocks') do
      expect(page).to have_content(interested_block.name)
      expect(page).not_to have_content(uninterested_block.name)
      click_on(I18n.t('generic.link.show'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.blocks.show', name: interested_block.name))
  end
end
