class AddAddedAtToDefects < ActiveRecord::Migration[5.2]
  def change
    add_column :defects, :added_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
