require 'rails_helper'

RSpec.feature 'Anyone can create a comment' do
  let!(:property) { create(:property, address: '1 Hackney Street') }
  let!(:defect) { create(:property_defect, property: property) }

  context 'when the defect is for a property' do
    let!(:property) { create(:property, address: '1 Hackney Street') }
    let!(:defect) { create(:property_defect, property: property) }

    scenario 'a property can be found and comment can be created' do
      visit root_path

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

      expect(page).to have_content(I18n.t('page_title.staff.comments.create'))

      click_on(I18n.t('generic.button.create', resource: 'Comment'))

      within('form.new_comment') do
        fill_in 'comment[message]', with: 'None of the electrics work'
        click_on(I18n.t('generic.button.create', resource: 'Comment'))
      end

      expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'comment'))

      within('.comments') do
        comment = Comment.first
        expect(page).to have_content(comment.message)
        expect(page).to have_content(comment.created_at)
        expect(page).to have_content(comment.message)
      end
    end
  end

  context 'when the defect is for a property' do
    let!(:block) { create(:block, name: 'Hackney Street') }
    let!(:defect) { create(:communal_defect, block: block) }

    scenario 'a block can be found and comment can be created' do
      visit root_path

      expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

      within('form.search') do
        fill_in 'query', with: 'Hackney'
        click_on(I18n.t('generic.button.find'))
      end

      within('.blocks') do
        click_on(I18n.t('generic.link.show'))
      end

      expect(page).to have_content(I18n.t('page_title.staff.blocks.show', name: block.name))

      within('.defects') do
        click_on(I18n.t('generic.link.show'))
      end

      expect(page).to have_content(I18n.t('page_title.staff.comments.create'))

      click_on(I18n.t('generic.button.create', resource: 'Comment'))

      within('form.new_comment') do
        fill_in 'comment[message]', with: 'None of the electrics work'
        click_on(I18n.t('generic.button.create', resource: 'Comment'))
      end

      expect(page).to have_content(I18n.t('generic.notice.create.success', resource: 'comment'))

      within('.comments') do
        comment = Comment.first
        "Comment left by Generic team user posted at 15:11pm on 24 June 2019 None of the electrics work"
        expect(page).to have_content(comment.message)
        expect(page).to have_content(comment.created_at)
        expect(page).to have_content(comment.message)
      end
    end
  end

  scenario 'an invalid comment cannot be submitted' do
    visit new_defect_comment_path(defect)

    expect(page).to have_content(I18n.t('page_title.staff.comments.create'))
    within('form.new_comment') do
      # Deliberately forget to fill out the required name field
      click_on(I18n.t('generic.button.create', resource: 'Comment'))
    end

    within('.comment_message') do
      expect(page).to have_content("can't be blank")
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
