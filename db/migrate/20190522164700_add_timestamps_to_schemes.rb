class AddTimestampsToSchemes < ActiveRecord::Migration[5.1]
  def change
    add_column :schemes, :created_at, :datetime
    add_column :schemes, :updated_at, :datetime

    Scheme.update_all created_at: Time.now
    Scheme.update_all updated_at: Time.now

    change_column :schemes, :created_at, :datetime, null:false
    change_column :schemes, :updated_at, :datetime, null:false
  end
end
