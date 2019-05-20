class CreateScheme < ActiveRecord::Migration[5.1]
  def change
    create_table :schemes, id: :uuid do |t|
      t.string :name, null: false
    end
  end
end
