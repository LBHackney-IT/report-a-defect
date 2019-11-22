class CreateEvidences < ActiveRecord::Migration[5.2]
  def change
    create_table :evidences, id: :uuid do |t|
      t.text :description
      t.belongs_to :defect, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end
  end
end
