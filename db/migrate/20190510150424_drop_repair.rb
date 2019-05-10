class DropRepair < ActiveRecord::Migration[5.1]
  def change
    drop_table(:repairs, force: true) if ActiveRecord::Base.connection.tables.include?('repairs')
  end
end
