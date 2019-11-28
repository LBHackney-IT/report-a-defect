class EmailDueSoonAndOverdueDefects
  attr_accessor :defects

  def initialize(defects:)
    self.defects = defects
  end

  def call
    DueSoonAndOverdueDefectsMailer.notify(
      defects.pluck(:id)
    ).deliver_later
  end
end
