# A collection of tasks used to trigger emails to the New Build Team about
# defects in the system.

namespace :notify do
  task escalated_defects: :environment do
    escalated_defects = Defect.open.flagged
    EmailEscalatedDefects.new(defects: escalated_defects).call
  end

  task due_soon_and_overdue_defects: :environment do
    due_soon_and_overdue_defects = Defect.overdue_and_due_soon
    EmailDueSoonAndOverdueDefects.new(defects: due_soon_and_overdue_defects).call
  end
end
