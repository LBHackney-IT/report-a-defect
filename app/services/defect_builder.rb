class DefectBuilder
  attr_accessor :defect,
                :defect_params,
                :priority_id,
                :created_at

  private

  def set_created_at
    date_parts = created_at.values_at(:day, :month, :year)
    return unless date_parts.all?(&:present?)

    day, month, year = date_parts.map(&:to_i)
    date = Date.new(year, month, day)
    defect.set_created_at(date)
  end
end
