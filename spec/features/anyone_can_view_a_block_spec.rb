require 'rails_helper'

RSpec.feature 'Anyone can view a block' do
  scenario 'a block can be found and viewed' do
    block = create(:block, name: 'Chipping')

    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.search') do
      fill_in 'query', with: 'Chipping'
      click_on(I18n.t('generic.button.find'))
    end

    click_on(I18n.t('generic.link.show'))

    expect(page).to have_content(I18n.t('page_title.staff.blocks.show', name: block.name))

    within('.block_information') do
      expect(page).to have_content(block.name)
    end
  end

  scenario 'can use breadcrumbs to navigate' do
    block = create(:block)

    visit block_path(block)

    within('.govuk-breadcrumbs') do
      expect(page).to have_link('Home', href: '/')
      expect(page).to have_link(
        I18n.t('page_title.staff.estates.show', name: block.scheme.estate.name),
        href: estate_path(block.scheme.estate)
      )
      expect(page).to have_link(
        I18n.t('page_title.staff.schemes.show', name: block.scheme.name),
        href: estate_scheme_path(block.scheme.estate, block.scheme)
      )
    end
  end
end
