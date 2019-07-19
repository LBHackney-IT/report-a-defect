require 'notifications/client'

class NotifyDefectSentToContractorJob < ApplicationJob
  queue_as :default

  def perform(defect_id)
    defect = Defect.find(defect_id)
    client.send_sms(
      phone_number: defect.contact_phone_number,
      template_id: Figaro.env.NOTIFY_DEFECT_SENT_TO_CONTRACTOR_TEMPLATE,
      personalisation: {
        short_title: defect.title,
        reference_number: defect.reference_number,
        contractor_name: defect.scheme.contractor_name,
        scheme_name: defect.scheme.name,
      }
    )
    defect.create_activity key: 'defect.notification.contact.sent_to_contractor', owner: nil
  end

  private

  def client
    @client ||= Notifications::Client.new(Figaro.env.NOTIFY_KEY)
  end
end
