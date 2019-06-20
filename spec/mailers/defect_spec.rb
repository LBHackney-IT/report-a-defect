require 'rails_helper'

RSpec.describe DefectMailer, type: :mailer do
  before(:each) do
    stub_const('NOTIFY_FORWARD_DEFECT_TEMPLATE', '')
    travel_to Time.zone.parse('2019-05-23')
  end

  after(:each) { travel_back }

  let(:recipient) { 'email@example.com' }
  let(:defect) { create(:defect) }

  describe('#forward_to_contractor') do
    it 'sends an email to the scheme contractor' do
      mail = DefectMailer.forward_to_contractor(defect.id)
      body_lines = mail.body.raw_source.lines
      expect(mail.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))
      expect(mail.to).to eq([defect.property.scheme.contractor_email_address])
      expect(body_lines[0].strip).to match(/# #{I18n.t('app.title')}/)
      expect(body_lines[2].strip).to match("#{I18n.t('email.defect.forward.headings.title.reference_number')} : #{defect.reference_number}")
      expect(body_lines[3].strip).to match("#{I18n.t('email.defect.forward.headings.title.created_at')}: #{defect.created_at.to_s(:default)}")
      expect(body_lines[4].strip).to match("#{I18n.t('email.defect.forward.headings.title.reporting_officer')}: Hackney New Build team")
      expect(body_lines[6].strip).to match("#{I18n.t('email.defect.forward.headings.title.address')}: #{defect.property.address}")
      expect(body_lines[7].strip).to match("#{I18n.t('email.defect.forward.headings.title.location')}: Property")
      expect(body_lines[9].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: #{defect.contact_name}")
      expect(body_lines[10].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_phone_number')}: #{defect.contact_phone_number}")
      expect(body_lines[11].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor_email_address')}: #{defect.contact_email_address}")
      expect(body_lines[13].strip).to match("#{I18n.t('email.defect.forward.headings.title.description_of_defect')}: #{defect.description}")
      expect(body_lines[14].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor')}: #{defect.property.scheme.contractor_name}")
      expect(body_lines[15].strip).to match("#{I18n.t('email.defect.forward.headings.title.priority_name')}: #{defect.priority.name}")
      expect(body_lines[16].strip).to match("#{I18n.t('email.defect.forward.headings.title.target_completion_date')}: #{defect.target_completion_date}")
      expect(body_lines[18]).to match(%r{http:\/\/localhost:3000\/defects\/#{defect.token}\/accept})
    end

    context 'when the name includes a single quote' do
      let(:defect) { create(:defect, contact_name: "Wilda O'Connell") }
      it 'sends an email to the scheme contractor' do
        mail = DefectMailer.forward_to_contractor(defect.id)
        body_lines = mail.body.raw_source.lines
        expect(body_lines[9].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: Wilda O'Connell")
      end
    end
  end

  describe('#forward_to_employer_agent') do
    it 'sends an email to the scheme employer_agent' do
      mail = DefectMailer.forward_to_employer_agent(defect.id)
      body_lines = mail.body.raw_source.lines
      expect(mail.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))
      expect(mail.to).to eq([defect.property.scheme.employer_agent_email_address])
      expect(body_lines[0].strip).to match(/# #{I18n.t('app.title')}/)
      expect(body_lines[2].strip).to match("#{I18n.t('email.defect.forward.headings.title.reference_number')} : #{defect.reference_number}")
      expect(body_lines[3].strip).to match("#{I18n.t('email.defect.forward.headings.title.created_at')}: #{defect.created_at.to_s(:default)}")
      expect(body_lines[4].strip).to match("#{I18n.t('email.defect.forward.headings.title.reporting_officer')}: Hackney New Build team")
      expect(body_lines[6].strip).to match("#{I18n.t('email.defect.forward.headings.title.address')}: #{defect.property.address}")
      expect(body_lines[7].strip).to match("#{I18n.t('email.defect.forward.headings.title.location')}: Property")
      expect(body_lines[9].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: #{defect.contact_name}")
      expect(body_lines[10].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_phone_number')}: #{defect.contact_phone_number}")
      expect(body_lines[11].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor_email_address')}: #{defect.contact_email_address}")
      expect(body_lines[13].strip).to match("#{I18n.t('email.defect.forward.headings.title.description_of_defect')}: #{defect.description}")
      expect(body_lines[14].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor')}: #{defect.property.scheme.contractor_name}")
      expect(body_lines[15].strip).to match("#{I18n.t('email.defect.forward.headings.title.priority_name')}: #{defect.priority.name}")
      expect(body_lines[16].strip).to match("#{I18n.t('email.defect.forward.headings.title.target_completion_date')}: #{defect.target_completion_date}")
    end

    context 'when the name includes a single quote' do
      let(:defect) { create(:defect, contact_name: "Wilda O'Connell") }
      it 'sends an email to the scheme contractor' do
        mail = DefectMailer.forward_to_contractor(defect.id)
        body_lines = mail.body.raw_source.lines
        expect(body_lines[9].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: Wilda O'Connell")
      end
    end
  end
end
