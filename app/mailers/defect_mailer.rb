class DefectMailer < ApplicationMailer
  def forward_to_contractor(defect_id)
    @defect = Defect.find(defect_id)

    view_mail(
      NOTIFY_FORWARD_DEFECT_TEMPLATE,
      to: @defect.scheme.contractor_email_address,
      subject: I18n.t('email.defect.forward.subject', reference: @defect.reference_number),
    )
  end

  def forward_to_employer_agent(defect_id)
    @defect = Defect.find(defect_id)

    view_mail(
      NOTIFY_FORWARD_DEFECT_TEMPLATE,
      to: @defect.scheme.employer_agent_email_address,
      subject: I18n.t('email.defect.forward.subject', reference: @defect.reference_number),
    )
  end
end
