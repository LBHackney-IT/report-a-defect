class CreateEstate < ActiveRecord::Migration[5.1]
  def change
    create_table :estates, id: :uuid do |t|
      t.string :name
      t.timestamps
    end
  end
end
