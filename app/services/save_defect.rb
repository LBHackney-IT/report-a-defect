class SaveDefect
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    defect.save

    send_to_contractor
    send_to_employer_agent
  end

  private

  def send_to_contractor
    DefectMailer.forward(
      'contractor',
      defect.scheme.contractor_email_address,
      defect.id
    ).deliver_later
  end

  def send_to_employer_agent
    DefectMailer.forward(
      'employer_agent',
      defect.scheme.employer_agent_email_address,
      defect.id
    ).deliver_later
  end
end
