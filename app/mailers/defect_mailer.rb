class DefectMailer < ApplicationMailer
  def forward(recipient_type, recipient_email_address, defect_id)
    @defect = Defect.find(defect_id)
    @presenter = DefectPresenter.new(@defect)

    view_mail(
      NOTIFY_FORWARD_DEFECT_TEMPLATE,
      to: recipient_email_address,
      subject: I18n.t('email.defect.forward.subject', reference: @defect.reference_number),
      template_name: template_for(recipient_type),
    )

    @defect.create_activity key: "defect.forwarded_to_#{recipient_type}", owner: nil
  end

  private

  def template_for(template_key)
    case template_key.to_sym
    when :contractor then 'forward_to_contractor'
    when :employer_agent then 'forward_to_employer_agent'
    end
  end
end
