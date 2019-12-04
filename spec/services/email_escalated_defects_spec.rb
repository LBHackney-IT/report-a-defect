require 'rails_helper'

RSpec.describe EmailEscalatedDefects do
  let(:defects) { create_list(:property_defect, 3) }

  describe '#call' do
    it 'emails the team' do
      team_message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(DefectsMailer).to receive(:escalated)
        .with(defects.pluck(:id))
        .and_return(team_message_delivery)
      expect(team_message_delivery).to receive(:deliver_later)

      described_class.new(defects: defects).call
    end
  end
end
