class DefectMailer < ApplicationMailer
  def forward(defect_id, recipient)
    @defect = Defect.find(defect_id)

    view_mail(
      NOTIFY_FORWARD_DEFECT_TEMPLATE,
      to: recipient,
      subject: I18n.t('email.defect.forward.subject', reference: @defect.reference_number),
    )
  end
end
