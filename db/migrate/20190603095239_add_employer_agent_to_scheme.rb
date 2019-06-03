class AddEmployerAgentToScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :schemes, :employer_agent_name, :string
    add_column :schemes, :employer_agent_email_address, :string
  end
end
