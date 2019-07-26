require 'notifications/client'

class NotifyDefectAcceptedByContractorJob < ApplicationJob
  queue_as :default

  def perform(defect_id)
    SendSms.new.defect_accepted_by_contractor(defect_id: defect_id)
  end
end
