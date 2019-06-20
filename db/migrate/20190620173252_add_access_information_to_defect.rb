class AddAccessInformationToDefect < ActiveRecord::Migration[5.2]
  def change
    add_column :defects, :access_information, :string
  end
end
