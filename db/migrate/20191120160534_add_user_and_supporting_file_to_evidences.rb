class AddUserAndSupportingFileToEvidences < ActiveRecord::Migration[5.2]
  def change
    add_reference :evidences, :user, foreign_key: true, index: true, type: :uuid
    add_column :evidences, :supporting_file, :string
  end
end
