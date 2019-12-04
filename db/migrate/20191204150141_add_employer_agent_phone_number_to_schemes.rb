class AddEmployerAgentPhoneNumberToSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :schemes, :employer_agent_phone_number, :string
  end
end
