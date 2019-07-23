class RemoveDefectsReferenceNumber < ActiveRecord::Migration[5.2]
  def change
    remove_column :defects, :reference_number
  end
end
