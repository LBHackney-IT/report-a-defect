class AddFlaggedToDefects < ActiveRecord::Migration[5.2]
  def change
    change_table :defects do |t|
      t.boolean :flagged, null: false, default: false
    end
  end
end
