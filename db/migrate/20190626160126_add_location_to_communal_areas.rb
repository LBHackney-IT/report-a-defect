class AddLocationToCommunalAreas < ActiveRecord::Migration[5.2]
  def up
    add_column :communal_areas, :location, :string
  end

  def down
    remove_column :communal_areas, :location
  end
end
