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

    EmailContractor.new(defect: defect).call if send_email_to_contractor
    EmailEmployerAgent.new(defect: defect).call if send_email_to_employer_agent
  end
end
