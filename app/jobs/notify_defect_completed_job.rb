require 'notifications/client'

class NotifyDefectCompletedJob < ApplicationJob
  queue_as :default

  def perform(defect_id)
    SendSms.new.defect_completed(defect_id: defect_id)
  end
end
