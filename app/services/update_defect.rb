class UpdateDefect
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    NotifyDefectCompletedJob.perform_later(defect.id) if defect.status_changed? && defect.completed?

    defect.save
    defect
  end
end
