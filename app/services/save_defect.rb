class SaveDefect
  attr_accessor :defect,
                :send_email_to_contractor,
                :send_email_to_employer_agent

  def initialize(defect:, send_email_to_contractor: true, send_email_to_employer_agent: true)
    self.defect = defect
    self.send_email_to_contractor = send_email_to_contractor
    self.send_email_to_employer_agent = send_email_to_employer_agent
  end

  def call
    defect.save

    send_to_contractor if send_email_to_contractor
    send_to_employer_agent if send_email_to_employer_agent
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
