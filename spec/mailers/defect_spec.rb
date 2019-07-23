require 'rails_helper'

RSpec.describe DefectMailer, type: :mailer do
  before(:each) do
    stub_const('NOTIFY_FORWARD_DEFECT_TEMPLATE', '')
    travel_to Time.zone.parse('2019-05-23')
  end

  after(:each) { travel_back }

  let(:defect) { create(:property_defect, contact_name: 'Bilbo') }
  let(:presenter) { DefectPresenter.new(defect) }

  describe('#forward') do
    it 'sends an email to contractors' do
      mail = DefectMailer.forward('contractor', defect.scheme.contractor_email_address, defect.id)
      body_lines = mail.body.raw_source.lines
      expect(mail.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))
      expect(mail.to).to eq([defect.scheme.contractor_email_address])
      expect(body_lines[0].strip).to match(/# #{I18n.t('app.title')}/)
      expect(body_lines[2].strip).to match("#{I18n.t('email.defect.forward.headings.title.reference_number')} : #{presenter.reference_number}")
      expect(body_lines[3].strip).to match("#{I18n.t('email.defect.forward.headings.title.created_at')}: #{presenter.created_time}")
      expect(body_lines[4].strip).to match("#{I18n.t('email.defect.forward.headings.title.reporting_officer')}: #{presenter.reporting_officer}")
      expect(body_lines[6].strip).to match("#{I18n.t('email.defect.forward.headings.title.address')}: #{presenter.address}")
      expect(body_lines[7].strip).to match("#{I18n.t('email.defect.forward.headings.title.access_information')}: #{presenter.access_information}")
      expect(body_lines[8].strip).to match("#{I18n.t('email.defect.forward.headings.title.defect_type')}: #{presenter.defect_type}")
      expect(body_lines[10].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: #{presenter.contact_name}")
      expect(body_lines[11].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_phone_number')}: #{presenter.contact_phone_number}")
      expect(body_lines[12].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor_email_address')}: #{presenter.contact_email_address}")
      expect(body_lines[14].strip).to match("#{I18n.t('email.defect.forward.headings.title.description_of_defect')}: #{presenter.description}")
      expect(body_lines[15].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor')}: #{presenter.contractor_name}")
      expect(body_lines[16].strip).to match("#{I18n.t('email.defect.forward.headings.title.priority_name')}: #{presenter.priority_name}")
      expect(body_lines[17].strip).to match("#{I18n.t('email.defect.forward.headings.title.target_completion_date')}: #{presenter.target_completion_date}")
      expect(body_lines[19]).to match(%r{http:\/\/localhost:3000\/defects\/#{defect.token}\/accept})
      expect(body_lines[20]).to match(I18n.t('email.defect.forward.rejection'))
    end

    it 'sends an email to employer_agent' do
      mail = DefectMailer.forward('employer_agent', defect.scheme.employer_agent_email_address, defect.id)
      body_lines = mail.body.raw_source.lines
      expect(mail.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))
      expect(mail.to).to eq([defect.scheme.employer_agent_email_address])
      expect(body_lines[0].strip).to match(/# #{I18n.t('app.title')}/)
      expect(body_lines[2].strip).to match("#{I18n.t('email.defect.forward.headings.title.reference_number')} : #{presenter.reference_number}")
      expect(body_lines[3].strip).to match("#{I18n.t('email.defect.forward.headings.title.created_at')}: #{presenter.created_time}")
      expect(body_lines[4].strip).to match("#{I18n.t('email.defect.forward.headings.title.reporting_officer')}: #{presenter.reporting_officer}")
      expect(body_lines[6].strip).to match("#{I18n.t('email.defect.forward.headings.title.address')}: #{presenter.address}")
      expect(body_lines[7].strip).to match("#{I18n.t('email.defect.forward.headings.title.access_information')}: #{presenter.access_information}")
      expect(body_lines[8].strip).to match("#{I18n.t('email.defect.forward.headings.title.defect_type')}: #{presenter.defect_type}")
      expect(body_lines[10].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: #{presenter.contact_name}")
      expect(body_lines[11].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_phone_number')}: #{presenter.contact_phone_number}")
      expect(body_lines[12].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor_email_address')}: #{presenter.contact_email_address}")
      expect(body_lines[14].strip).to match("#{I18n.t('email.defect.forward.headings.title.description_of_defect')}: #{presenter.description}")
      expect(body_lines[15].strip).to match("#{I18n.t('email.defect.forward.headings.title.contractor')}: #{presenter.contractor_name}")
      expect(body_lines[16].strip).to match("#{I18n.t('email.defect.forward.headings.title.priority_name')}: #{presenter.priority_name}")
      expect(body_lines[17].strip).to match("#{I18n.t('email.defect.forward.headings.title.target_completion_date')}: #{presenter.target_completion_date}")
    end

    context 'when the name includes a single quote' do
      let(:defect) { create(:property_defect, contact_name: "Wilda O'Connell") }
      it 'escapes the value' do
        mail = DefectMailer.forward('contractor', defect.scheme.contractor_email_address, defect.id)
        body_lines = mail.body.raw_source.lines
        expect(body_lines[10].strip).to match("#{I18n.t('email.defect.forward.headings.title.contact_name')}: Wilda O&#39;Connell")
      end
    end

    it 'stores sending of an email to the contractor in a custom activity record' do
      travel_to Time.zone.parse('2019-05-23')

      DefectMailer.forward('contractor', defect.scheme.contractor_email_address, defect.id).deliver_now

      result = PublicActivity::Activity.find_by(
        trackable_id: defect.id, trackable_type: Defect.to_s, key: 'defect.forwarded_to_contractor'
      )
      expect(result).to be_kind_of(PublicActivity::Activity)
      expect(result.trackable).to be_kind_of(Defect)
      expect(result.created_at).to eq(Time.zone.now)

      travel_back
    end

    it 'stores sending of an email to the employer agent in a custom activity record' do
      travel_to Time.zone.parse('2019-05-23')

      DefectMailer.forward('employer_agent', defect.scheme.employer_agent_email_address, defect.id).deliver_now

      result = PublicActivity::Activity.find_by(
        trackable_id: defect.id, trackable_type: Defect.to_s, key: 'defect.forwarded_to_employer_agent'
      )
      expect(result).to be_kind_of(PublicActivity::Activity)
      expect(result.trackable).to be_kind_of(Defect)
      expect(result.created_at).to eq(Time.zone.now)

      travel_back
    end
  end
end
