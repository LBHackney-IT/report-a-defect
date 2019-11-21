class PopulateAddedAtOnDefects < ActiveRecord::Migration[5.2]
  def up
    Defect.find_each do |defect|
      defect.update(added_at: defect.created_at)
    end
  end
end
