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
    defect_attributes = build(:property_defect).attributes
    defect_attributes.merge!(priority: create(:priority).id)
    params = {
      defect: defect_attributes,
    }

    contractor_message_delivery = instance_double(ActionMailer::MessageDelivery)
    expect(DefectMailer).to receive(:forward)
      .with('contractor', property.scheme.contractor_email_address, anything)
      .and_return(contractor_message_delivery)
    expect(contractor_message_delivery).to receive(:deliver_later)

    employer_agent_message_delivery = instance_double(ActionMailer::MessageDelivery)
    expect(DefectMailer).to receive(:forward)
      .with('employer_agent', property.scheme.employer_agent_email_address, anything)
      .and_return(employer_agent_message_delivery)
    expect(employer_agent_message_delivery).to receive(:deliver_later)

    post property_defects_path(property), params: params
  end
end
