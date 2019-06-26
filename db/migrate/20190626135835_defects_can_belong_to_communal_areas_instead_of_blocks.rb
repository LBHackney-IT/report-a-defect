class DefectsCanBelongToCommunalAreasInsteadOfBlocks < ActiveRecord::Migration[5.2]
  def change
    remove_reference :defects, :block
    add_reference :defects, :communal_area, index: true, type: :uuid
  end
end
