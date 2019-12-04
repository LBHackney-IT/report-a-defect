require 'rails_helper'

RSpec.describe EmailEscalatedDefects do
  let!(:defects) { create_list(:property_defect, 1, status: :outstanding, flagged: true) }

  describe '#call' do
    it 'emails the team' do
      described_class.new.call

      expect(ActionMailer::DeliveryJob).to have_been_enqueued.with('DefectsMailer',
                                                                   'escalated',
                                                                   'deliver_now',
                                                                   defects.pluck(:id))
    end
  end
end
