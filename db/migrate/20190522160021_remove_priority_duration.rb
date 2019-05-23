class RemovePriorityDuration < ActiveRecord::Migration[5.1]
  def up
    remove_column :priorities, :duration
  end

  def down
    add_column :priorities, :duration, :string
  end
end
