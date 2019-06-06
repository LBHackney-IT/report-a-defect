class SaveDefect
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    defect.save
    DefectMailer.forward(defect.id).deliver_now
  end
end
