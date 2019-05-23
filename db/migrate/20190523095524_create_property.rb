class CreateProperty < ActiveRecord::Migration[5.1]
  def change
    create_table :properties, id: :uuid do |t|
      t.string :core_name
      t.string :address
      t.string :postcode
      t.references :scheme, foreign_key: true, index: true, type: :uuid
      t.timestamps
    end
  end
end
