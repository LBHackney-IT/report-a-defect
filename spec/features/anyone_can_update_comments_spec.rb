require 'rails_helper'

RSpec.feature 'anyone can update comments' do
  let(:property) { create(:property) }
  let(:defect) { create(:property_defect, property: property) }

  scenario 'a comment can be edited' do
    create(:comment, defect: defect)

    visit property_defect_path(property, defect)

    within('.comment') do
      click_on(I18n.t('generic.link.edit'))
    end

    expect(page).to have_content(I18n.t('page_title.staff.comments.edit'))

    within('form.edit_comment') do
      fill_in 'comment[message]', with: 'None of the electrics work'
      click_on(I18n.t('generic.button.update', resource: 'Comment'))
    end

    expect(page).to have_content(I18n.t('generic.notice.update.success', resource: 'comment'))

    within('.comment') do
      expect(page).to have_content('None of the electrics work')
    end
  end
end
