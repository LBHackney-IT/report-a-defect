class AddProjectManagerToSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :schemes, :project_manager_name, :string
    add_column :schemes, :project_manager_email_address, :string
  end
end
