class AddUprnToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :uprn, :string
    add_index :properties, :uprn, unique: true
  end
end
