class AddTitleToDefect < ActiveRecord::Migration[5.2]
  def change
    add_column :defects, :title, :string
  end
end
