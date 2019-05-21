class CreatePriority < ActiveRecord::Migration[5.1]
  def change
    create_table :priorities do |t|
      t.string :name
      t.string :duration
      t.references :scheme, foreign_key: true, index: true, type: :uuid
      t.timestamps
    end
  end
end
