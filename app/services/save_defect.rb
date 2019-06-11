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
    DefectMailer.forward_to_contractor(defect.id).deliver_now
    defect.create_activity key: 'defect.forwarded_to_contractor', owner: nil
  end

  def send_to_employer_agent
    DefectMailer.forward_to_employer_agent(defect.id).deliver_now
    defect.create_activity key: 'defect.forwarded_to_employer_agent', owner: nil
  end
end
