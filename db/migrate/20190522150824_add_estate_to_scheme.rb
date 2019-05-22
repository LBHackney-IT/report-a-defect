class AddEstateToScheme < ActiveRecord::Migration[5.1]
  def change
    add_reference :schemes, :estate, foreign_key: true, index: true, type: :uuid
  end
end
