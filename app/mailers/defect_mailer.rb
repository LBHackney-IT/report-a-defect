class DefectMailer < ApplicationMailer
  def forward(defect_id)
    defect = Defect.find(defect_id)

    @defect_reference = defect.reference_number

    view_mail(
      NOTIFY_FORWARD_DEFECT_TEMPLATE,
      to: defect.property.scheme.contractor_email_address,
      subject: I18n.t('email.defect.forward.subject', reference: defect.reference_number),
    )
  end
end
