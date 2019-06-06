require 'rails_helper'

RSpec.describe DefectMailer, type: :mailer do
  before(:each) do
    stub_const('NOTIFY_FORWARD_DEFECT_TEMPLATE', '')
    travel_to Time.zone.parse('2019-05-23')
  end

  after(:each) { travel_back }

  let(:defect) { create(:defect) }
  let(:mail) { DefectMailer.forward(defect.id) }
  let(:body_lines) { mail.body.raw_source.lines }

  it 'sends an email to the contractor' do
    expect(mail.subject).to eq(I18n.t('email.defect.forward.subject', reference: defect.reference_number))
    expect(mail.to).to eq([defect.property.scheme.contractor_email_address])
    expect(body_lines[0]).to match(/# #{I18n.t('app.title')}/)
  end
end
