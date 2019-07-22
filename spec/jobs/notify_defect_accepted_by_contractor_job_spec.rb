require 'rails_helper'

RSpec.describe NotifyDefectAcceptedByContractorJob, type: :job do
  let(:fake_notify_key) { '123-456-789' }
  let(:fake_notify_template) { 'dsfgsdfgsd-43df-gdf8-sg55-ebs454gs' }
  let(:defect) { create(:property_defect, contact_phone_number: '07123456789') }
  let(:sent_message_double) { double(:sent_message, content: { body: 'Lorem ipsum' }) }

  before(:each) do
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(:NOTIFY_KEY).and_return(fake_notify_key)
    allow(fake_env).to receive(:NOTIFY_DEFECT_ACCEPTED_BY_CONTRACTOR_TEMPLATE).and_return(fake_notify_template)
  end

  describe '#perform_later' do
    it 'enqueues a job asynchronously on the default queue' do
      ActiveJob::Base.queue_adapter = :test

      expect do
        described_class.perform_later(defect.id)
      end.to have_enqueued_job.with(defect.id).on_queue('default')
    end

    it 'asks GOV.UK Notify to send an SMS' do
      notify_client = double(Notifications::Client, send_sms: sent_message_double)
      expect(Notifications::Client)
        .to receive(:new)
        .with(fake_notify_key)
        .and_return(notify_client)

      expect(notify_client)
        .to receive(:send_sms)
        .with(
          personalisation: {
            contractor_name: defect.scheme.contractor_name,
            reference_number: defect.reference_number,
            short_title: defect.title,
          },
          phone_number: defect.contact_phone_number,
          template_id: fake_notify_template
        )

      described_class.perform_now(defect.id)
    end

    it 'stores an activity event' do
      notify_client = double(Notifications::Client, send_sms: sent_message_double)
      expect(Notifications::Client)
        .to receive(:new)
        .with(fake_notify_key)
        .and_return(notify_client)

      described_class.perform_now(defect.id)
      expect(PublicActivity::Activity.where(key: 'defect.notification.contact.accepted_by_contractor').count).to eq(1)
    end

    context 'when the defect does not have a contact_phone_number' do
      let(:defect) { create(:property_defect, contact_phone_number: nil) }
      it 'does not enqueue a job' do
        expect_any_instance_of(Notifications::Client).not_to receive(:send_sms)
        described_class.perform_now(defect.id)
      end

      it 'does not create an activity event' do
        described_class.perform_now(defect.id)
        expect(PublicActivity::Activity.where(key: 'defect.notification.contact.accepted_by_contractor').count).to eq(0)
      end
    end
  end
end
