class AddStartDateToSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :schemes, :start_date, :date
  end
end
