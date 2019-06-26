class RenameBlocksToCommunalArea < ActiveRecord::Migration[5.2]
  def change
    rename_table :blocks, :communal_areas
  end
end
