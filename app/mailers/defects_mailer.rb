class DefectsMailer < ApplicationMailer
  attr_accessor :notify_template

  def due_soon_and_overdue(defect_ids)
    @defects = Defect.find(defect_ids).map { |defect| DefectPresenter.new(defect) }
    self.notify_template = NOTIFY_DAILY_DUE_SOON_TEMPLATE
    notify('due_soon_and_overdue')
  end

  def escalated(defect_ids)
    @defects = Defect.find(defect_ids).map { |defect| DefectPresenter.new(defect) }
    self.notify_template = NOTIFY_DAILY_ESCALATION_TEMPLATE
    notify('escalated')
  end

  def notify(template)
    @template = template

    view_mail(
      notify_template,
      to: NBT_GROUP_EMAIL,
      subject: I18n.t("email.defects.#{template}.subject", count: @defects.count),
      template_name: 'notify',
    )
  end
end
