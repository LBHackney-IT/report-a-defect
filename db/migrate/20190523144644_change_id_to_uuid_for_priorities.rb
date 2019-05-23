class ChangeIdToUuidForPriorities < ActiveRecord::Migration[5.2]
  def change
    remove_column :priorities, :id
    rename_column :priorities, :uuid, :id
    execute "ALTER TABLE priorities ADD PRIMARY KEY (id);"
  end
end
