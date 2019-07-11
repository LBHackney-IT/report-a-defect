class AllowNullDefectsReferenceNumber < ActiveRecord::Migration[5.2]
  def change
    change_column :defects, :reference_number, :string, null: true
  end
end
