class SaveDefect
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    defect.save
    DefectMailer.forward(defect.id).deliver_now
    defect.create_activity key: 'defect.forwarded_to_contractor', owner: nil
  end
end
