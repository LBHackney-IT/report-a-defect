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

    it 'forwards the email to the contractor and employer agent by default' do
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

      post property_defects_url(property), params: params
    end

    context 'when the email should not be sent automatically' do
      it 'forwards the email to the contractor and employer agent' do
        defect_attributes = build(:property_defect).attributes
        defect_attributes.merge!(
          priority: create(:priority).id,
          send_contractor_email: '0',
          send_employer_agent_email: '0',
        )

        params = {
          defect: defect_attributes,
        }

        expect(DefectMailer).not_to receive(:forward)
          .with('contractor', property.scheme.contractor_email_address, anything)

        expect(DefectMailer).not_to receive(:forward)
          .with('employer_agent', property.scheme.employer_agent_email_address, anything)

        post property_defects_url(property), params: params
      end
    end
  end

  context 'when the defect is for a communal_area' do
    let(:communal_area) { create(:communal_area) }

    it 'forwards the email to the contractor and employer agent by default' do
      defect_attributes = build(:communal_defect).attributes
      defect_attributes.merge!(priority: create(:priority).id)
      params = {
        defect: defect_attributes,
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

      post communal_area_defects_url(communal_area), params: params
    end

    context 'when the email should not be sent automatically' do
      it 'forwards the email to the contractor and employer agent' do
        defect_attributes = build(:communal_defect).attributes
        defect_attributes.merge!(
          priority: create(:priority).id,
          send_contractor_email: '0',
          send_employer_agent_email: '0',
        )

        params = {
          defect: defect_attributes,
        }

        expect(DefectMailer).not_to receive(:forward)
          .with('contractor', communal_area.scheme.contractor_email_address, anything)

        expect(DefectMailer).not_to receive(:forward)
          .with('employer_agent', communal_area.scheme.employer_agent_email_address, anything)

        post communal_area_defects_url(communal_area), params: params
      end
    end
  end
end
