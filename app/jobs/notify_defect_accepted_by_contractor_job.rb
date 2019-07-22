require 'notifications/client'

class NotifyDefectAcceptedByContractorJob < ApplicationJob
  queue_as :default

  def perform(defect_id)
    defect = Defect.find(defect_id)
    return if defect.contact_phone_number.blank?

    client.send_sms(
      phone_number: defect.contact_phone_number,
      template_id: Figaro.env.NOTIFY_DEFECT_ACCEPTED_BY_CONTRACTOR_TEMPLATE,
      personalisation: {
        short_title: defect.title,
        reference_number: defect.reference_number,
        contractor_name: defect.scheme.contractor_name,
      }
    )
    defect.create_activity key: 'defect.notification.contact.accepted_by_contractor', owner: nil
  end

  private

  def client
    @client ||= Notifications::Client.new(Figaro.env.NOTIFY_KEY)
  end
end
