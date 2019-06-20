class CreateBlock < ActiveRecord::Migration[5.2]
  def change
    create_table :blocks, id: :uuid do |t|
      t.string :name
      t.references :scheme, foreign_key: true, index: true, type: :uuid
      t.timestamps
    end
  end
end
