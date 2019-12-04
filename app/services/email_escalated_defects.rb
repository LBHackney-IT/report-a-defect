class EmailEscalatedDefects
  attr_accessor :defects

  def initialize
    self.defects = Defect.open
                         .flagged
                         .order(:target_completion_date)
  end

  def call
    DefectsMailer.escalated(defects.pluck(:id)).deliver_later
  end
end
