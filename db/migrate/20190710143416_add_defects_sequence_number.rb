class AddDefectsSequenceNumber < ActiveRecord::Migration[5.2]
  def change
    change_table :defects do |t|
      t.serial :sequence_number, null: false
      t.index :sequence_number, unique: true
    end
  end
end
