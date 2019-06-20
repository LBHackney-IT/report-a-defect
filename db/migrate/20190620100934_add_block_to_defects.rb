class AddBlockToDefects < ActiveRecord::Migration[5.2]
  def change
    add_reference :defects, :block, index: true, type: :uuid
  end
end
