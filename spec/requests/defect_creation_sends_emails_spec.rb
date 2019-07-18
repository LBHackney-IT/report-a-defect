require 'rails_helper'

RSpec.describe 'Defect creation', type: :request do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    allow_any_instance_of(Secured)
      .to receive(:logged_in_using_omniauth?)
      .and_return(true)
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'when the defect is for a property' do
    let(:property) { create(:property) }

    it 'forwards the email to the contractor and employer agent' do
      defect_attributes = build(:property_defect).attributes
      defect_attributes.merge!(priority: create(:priority).id)
      params = {
        defect: defect_attributes,
        send_email_to_contractor: 'true',
        send_email_to_employer_agent: 'true',
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

  context 'when the defect is for a communal_area' do
    let(:communal_area) { create(:communal_area) }

    it 'forwards the email to the contractor and employer agent' do
      defect_attributes = build(:communal_defect).attributes
      defect_attributes.merge!(priority: create(:priority).id)
      params = {
        defect: defect_attributes,
        send_email_to_contractor: 'true',
        send_email_to_employer_agent: 'true',
      }

      contractor_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward)
        .with('contractor', communal_area.scheme.contractor_email_address, anything)
        .and_return(contractor_message_delivery)
      expect(contractor_message_delivery).to receive(:deliver_later)

      employer_agent_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectMailer).to receive(:forward)
        .with('employer_agent', communal_area.scheme.employer_agent_email_address, anything)
        .and_return(employer_agent_message_delivery)
      expect(employer_agent_message_delivery).to receive(:deliver_later)

      post communal_area_defects_path(communal_area), params: params
    end
  end
end
