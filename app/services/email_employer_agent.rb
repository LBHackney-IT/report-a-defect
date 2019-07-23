class EmailEmployerAgent
  attr_accessor :defect

  def initialize(defect:)
    self.defect = defect
  end

  def call
    DefectMailer.forward(
      'employer_agent',
      defect.scheme.employer_agent_email_address,
      defect.id
    ).deliver_later
  end
end
