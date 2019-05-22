class AddPriorityDurationAsInteger < ActiveRecord::Migration[5.1]
  def change
    add_column :priorities, :days, :integer
  end
end
