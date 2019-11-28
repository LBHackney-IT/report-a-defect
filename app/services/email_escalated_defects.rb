class EmailEscalatedDefects
  attr_accessor :defects

  def initialize(defects:)
    self.defects = defects
  end

  def call
    DefectsMailer.notify(
      'escalated',
      defects.pluck(:id)
    ).deliver_later
  end
end
