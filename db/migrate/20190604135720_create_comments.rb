class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments, id: :uuid do |t|
      t.string :message
      t.references :user, foreign_key: true, index: true, type: :uuid
      t.references :defect, foreign_key: true, index: true, type: :uuid
      t.timestamps
    end
  end
end
