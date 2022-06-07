require 'rails_helper'

RSpec.describe DefectsMailer, type: :mailer do
  before(:each) do
    stub_const('NOTIFY_DAILY_DUE_SOON_TEMPLATE', '1')
    stub_const('NOTIFY_DAILY_ESCALATION_TEMPLATE', '2')
    stub_const('NBT_GROUP_EMAIL', 'test@email.com')
  end

  let(:property_defects) { create_list(:property_defect, 2) }
  let(:defects) { property_defects.map { |defect| DefectPresenter.new(defect) } }

  describe('#notify') do
    it 'sends an email about due soon and overdue defects' do
      mail = DefectsMailer.due_soon_and_overdue(defects.pluck(:id))
      body_lines = mail.body.raw_source.lines
      first_defect_line = body_lines[4].strip
      second_defect_line = body_lines[8].strip

      expect(mail.subject).to eq(I18n.t('email.defects.due_soon_and_overdue.subject', count: 2))
      expect(mail.to).to eq([NBT_GROUP_EMAIL])
      expect(body_lines[0].strip).to match(/# #{I18n.t('app.title')}/)
      expect(body_lines[2].strip).to match(I18n.t('email.defects.due_soon_and_overdue.heading'))

      expect(first_defect_line).to include(defects.first.reference_number)
      expect(first_defect_line).to include(defects.first.target_completion_date)
      expect(first_defect_line).to include(defects.first.priority.name)

      expect(second_defect_line).to include(defects.last.reference_number)
      expect(second_defect_line).to include(defects.last.target_completion_date)
      expect(second_defect_line).to include(defects.last.priority.name)
    end

    it 'sends an email about escalated defects' do
      mail = DefectsMailer.escalated(defects.pluck(:id))
      body_lines = mail.body.raw_source.lines
      first_defect_line = body_lines[4].strip
      second_defect_line = body_lines[8].strip

      expect(mail.subject).to eq(I18n.t('email.defects.escalated.subject', count: 2))
      expect(mail.to).to eq([NBT_GROUP_EMAIL])
      expect(body_lines[0].strip).to match(/# #{I18n.t('app.title')}/)
      expect(body_lines[2].strip).to match(I18n.t('email.defects.escalated.heading'))

      expect(first_defect_line).to include(defects.first.reference_number)
      expect(first_defect_line).to include(defects.first.target_completion_date)
      expect(first_defect_line).to include(defects.first.priority.name)

      expect(second_defect_line).to include(defects.last.reference_number)
      expect(second_defect_line).to include(defects.last.target_completion_date)
      expect(second_defect_line).to include(defects.last.priority.name)
    end
  end
end
