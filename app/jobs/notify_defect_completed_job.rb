require 'notifications/client'

class NotifyDefectCompletedJob < ApplicationJob
  queue_as :default

  def perform(defect_id)
    defect = Defect.find(defect_id)
    return if defect.contact_phone_number.blank?

    client.send_sms(
      phone_number: defect.contact_phone_number,
      template_id: Figaro.env.NOTIFY_DEFECT_COMPLETED_TEMPLATE,
      personalisation: {
        short_title: defect.title,
        reference_number: defect.reference_number,
      }
    )
    defect.create_activity key: 'defect.notification.contact.completed', owner: nil
  end

  private

  def client
    @client ||= Notifications::Client.new(Figaro.env.NOTIFY_KEY)
  end
end
