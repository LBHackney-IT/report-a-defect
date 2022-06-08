module DefectBuilder
  attr_accessor :defect,
                :defect_params,
                :priority_id,
                :created_at

  private

  def set_created_at
    date = BuildDate.new(created_at).call
    defect.set_created_at(date) if date.present?
  end
end
