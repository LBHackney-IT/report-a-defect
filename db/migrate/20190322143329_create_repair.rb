class CreateRepair < ActiveRecord::Migration[5.1]
  def change
    create_table :repairs do |t|
      t.string :description, null: false
    end
  end
end
