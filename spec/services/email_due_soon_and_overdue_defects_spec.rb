require 'rails_helper'

RSpec.describe EmailDueSoonAndOverdueDefects do
  let!(:defects) { create_list(:property_defect, 1, status: :outstanding, target_completion_date: 1.day.since) }

  describe '#call' do
    it 'emails the team' do
      described_class.new.call

      expect(ActionMailer::DeliveryJob).to have_been_enqueued.with('DefectsMailer',
                                                                   'due_soon_and_overdue',
                                                                   'deliver_now',
                                                                   defects.pluck(:id))
    end
  end
end
