require 'rails_helper'

RSpec.describe 'Defect creation', type: :request do
  let(:property) { create(:property) }

  it 'sends email to contractor' do
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

    message_delivery = instance_double(ActionMailer::MessageDelivery)
    expect(DefectMailer).to receive(:forward).with(anything) { message_delivery }
    expect(message_delivery).to receive(:deliver_now)

    post property_defects_path(property), params: params
  end
end
