class AddActualCompletionDateToDefects < ActiveRecord::Migration[5.2]
  def change
    change_table :defects do |t|
      t.date :actual_completion_date
    end
  end
end
