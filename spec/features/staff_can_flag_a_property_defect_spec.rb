require 'rails_helper'

RSpec.feature 'Staff can flag a property defect' do
  before(:each) do
    stub_authenticated_session
  end

  scenario 'flagging a defect' do
    defect = create(:property_defect, flagged: false)

    visit property_defect_path(defect.property, defect)
    click_button I18n.t('button.flag.add')

    expect(defect.reload).to be_flagged
  end

  scenario 'unflagging a defect' do
    defect = create(:property_defect, flagged: true)

    visit property_defect_path(defect.property, defect)
    click_button I18n.t('button.flag.remove')

    expect(defect.reload).not_to be_flagged
  end
end
