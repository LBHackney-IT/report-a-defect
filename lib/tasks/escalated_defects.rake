# A collection of tasks used to trigger emails to the New Build Team about
# defects in the system.

namespace :notify do
  task escalated_defects: :environment do
    EmailEscalatedDefects.new.call
  end

  task due_soon_and_overdue_defects: :environment do
    EmailDueSoonAndOverdueDefects.new.call
  end
end
