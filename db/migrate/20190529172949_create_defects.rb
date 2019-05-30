class CreateDefects < ActiveRecord::Migration[5.2]
  def change
    create_table :defects, id: :uuid do |t|
      t.string :description
      t.string :contact_name
      t.string :contact_email_address
      t.string :contact_phone_number
      t.string :trade
      t.date :target_completion_date
      t.integer :status, default: 0
      t.string :reference_number, null: false
      t.references :property, foreign_key: true, index: true, type: :uuid
      t.references :priority, foreign_key: true, index: true, type: :uuid
      t.timestamps
    end
  end
end
