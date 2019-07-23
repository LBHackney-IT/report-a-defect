class SendSms
  def defect_accepted_by_contractor(defect_id:)
    defect = Defect.find(defect_id)
    return if prevent_sms?(phone_number: defect.contact_phone_number)

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

  def defect_completed(defect_id:)
    defect = Defect.find(defect_id)
    return if prevent_sms?(phone_number: defect.contact_phone_number)

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

  def sent_to_contractor(defect_id:)
    defect = Defect.find(defect_id)
    return if prevent_sms?(phone_number: defect.contact_phone_number)

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

  def prevent_sms?(phone_number:)
    return true if phone_number.nil?
    return true if Figaro.env.SMS_BLACKLIST == phone_number
    false
  end
end
