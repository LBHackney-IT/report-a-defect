class DueSoonAndOverdueDefectsMailer < ApplicationMailer
  def notify(defect_ids)
    @defects = Defect.find(defect_ids).map { |defect| DefectPresenter.new(defect) }
    view_mail(
      NOTIFY_DAILY_DUE_SOON_TEMPLATE,
      to: NBT_GROUP_EMAIL,
      subject: I18n.t('email.defects.due_soon_and_overdue.subject'),
      template_name: 'notify',
    )
  end
end
