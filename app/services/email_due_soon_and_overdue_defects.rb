class EmailDueSoonAndOverdueDefects
  attr_accessor :defects

  def initialize
    self.defects = Defect.overdue_and_due_soon
                         .order(:target_completion_date)
  end

  def call
    DefectsMailer.due_soon_and_overdue(defects.pluck(:id)).deliver_later
  end
end
