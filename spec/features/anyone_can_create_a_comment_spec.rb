require 'rails_helper'

RSpec.feature 'Anyone can create a comment' do
  let!(:property) { create(:property, address: '1 Hackney Street') }
  let!(:defect) { create(:defect, property: property) }

  scenario 'a property can be found and comment can be created' do
    visit root_path

    expect(page).to have_content(I18n.t('page_title.staff.dashboard'))

    within('form.property-search') do
      fill_in 'address', with: 'Hackney'
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

  # scenario 'an invalid comment cannot be submitted' do
  #   property = create(:property)
  #
  #   visit property_path(property)
  #
  #   click_on(I18n.t('generic.button.create', resource: 'Defect'))
  #
  #   expect(page).to have_content(I18n.t('page_title.staff.comments.create'))
  #   within('form.new_comment') do
  #     # Deliberately forget to fill out the required name field
  #     click_on(I18n.t('generic.button.create', resource: 'Defect'))
  #   end
  #
  #   within('.comment_description') do
  #     expect(page).to have_content("can't be blank")
  #   end
  #
  #   within('.comment_trade') do
  #     expect(page).to have_content("can't be blank")
  #   end
  #
  #   within('.comment_priority') do
  #     expect(page).to have_content("can't be blank")
  #   end
  # end

  # TODO: navigation back button
end
