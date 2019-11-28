class DefectsMailer < ApplicationMailer
  def notify(template, defect_ids)
    @defects = Defect.find(defect_ids).map { |defect| DefectPresenter.new(defect) }
    @template = template

    view_mail(
      template_for(template),
      to: NBT_GROUP_EMAIL,
      subject: I18n.t("email.defects.#{template}.subject", count: @defects.count),
      template_name: 'notify',
    )
  end

  def template_for(template)
    case template.to_sym
    when :due_soon_and_overdue then NOTIFY_DAILY_DUE_SOON_TEMPLATE
    when :escalated then NOTIFY_DAILY_ESCALATION_TEMPLATE
    end
  end
end
