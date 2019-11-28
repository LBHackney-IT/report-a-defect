class EmailDueSoonAndOverdueDefects
  attr_accessor :defects

  def initialize(defects:)
    self.defects = defects
  end

  def call
    DefectsMailer.notify(
      'due_soon_and_overdue',
      defects.pluck(:id)
    ).deliver_later
  end
end
