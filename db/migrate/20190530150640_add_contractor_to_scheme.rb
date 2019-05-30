class AddContractorToScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :schemes, :contractor_name, :string
    add_column :schemes, :contractor_email_address, :string
  end
end
