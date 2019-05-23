class AddUuidToPriorities < ActiveRecord::Migration[5.2]
  def up
    add_column :priorities, :uuid, :uuid, default: "gen_random_uuid()", null: false
  end
end
