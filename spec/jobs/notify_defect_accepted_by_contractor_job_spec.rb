require 'rails_helper'

RSpec.describe NotifyDefectAcceptedByContractorJob, type: :job do
  let(:defect) { create(:property_defect, contact_phone_number: '07123456789') }
  before(:each) { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    it 'enqueues a job asynchronously on the default queue' do
      expect do
        described_class.perform_later(defect.id)
      end.to have_enqueued_job.with(defect.id).on_queue('default')
    end

    it 'asks SendSMS to send a text message' do
      expect_any_instance_of(SendSms).to receive(:defect_accepted_by_contractor)
      described_class.perform_now(defect.id)
    end
  end
end
