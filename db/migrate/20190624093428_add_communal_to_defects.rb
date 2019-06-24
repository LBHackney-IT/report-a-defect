class AddCommunalToDefects < ActiveRecord::Migration[5.2]
  def up
    add_column :defects, :communal, :boolean, default: false
  end

  def down
    remove_column :defects, :communal
  end
end
