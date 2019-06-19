class RemoveCoreFromProperty < ActiveRecord::Migration[5.2]
  def up
    remove_column :properties, :core_name
  end

  def down
    add_column :properties, :core_name, :string
  end
end
