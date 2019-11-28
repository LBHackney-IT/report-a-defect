class DueSoonAndOverdueDefectsMailer < ApplicationMailer
  def notify(defect_ids)
    @defects = Defect.find(defect_ids)
  end
end
