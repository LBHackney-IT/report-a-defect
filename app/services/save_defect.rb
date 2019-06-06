class SaveDefect
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    defect.save
  end
end
