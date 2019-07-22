class EmailContractor
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    DefectMailer.forward(
      'contractor',
      defect.scheme.contractor_email_address,
      defect.id
    ).deliver_later
  end
end
