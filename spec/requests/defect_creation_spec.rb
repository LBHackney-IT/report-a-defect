require 'rails_helper'

RSpec.describe 'Defect creation', type: :request do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  let(:property) { create(:property) }

  it 'forwards the email to the contractor and employer agent' do
    params = {
      defect: {
        description: 'A description',
        contact_name: 'A name',
        contact_email_address: 'email@example.com',
        contact_phone_number: '07123456789',
        trade: 'Electrical',
        status: 'outstanding',
        priority: create(:priority).id,
      },
    }

    post property_defects_path(property), params: params

    created_defect = Defect.last

    first_delivery = ActionMailer::Base.deliveries[0]

    expect(first_delivery.to).to eq([property.scheme.contractor_email_address])
    expect(first_delivery.subject)
      .to eq(I18n.t('email.defect.forward.subject', reference: created_defect.reference_number))

    second_delivery = ActionMailer::Base.deliveries[1]

    expect(second_delivery.to).to eq([property.scheme.employer_agent_email_address])
    expect(second_delivery.subject)
      .to eq(I18n.t('email.defect.forward.subject', reference: created_defect.reference_number))
  end
end
