require 'notifications/client'

class NotifyDefectSentToContractorJob < ApplicationJob
  queue_as :default

  def perform(defect_id)
    SendSms.new.sent_to_contractor(defect_id: defect_id)
  end
end
