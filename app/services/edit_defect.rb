class EditDefect
  attr_accessor :defect,
                :defect_params,
                :priority_id,
                :target_completion_date,
                :actual_completion_date

  def initialize(defect:, defect_params:, options: {})
    self.defect = defect
    self.defect_params = defect_params
    self.priority_id = options[:priority_id]
    self.target_completion_date = options.fetch(:target_completion_date, {})
    self.actual_completion_date = options.fetch(:actual_completion_date, {})
  end

  def call
    defect.assign_attributes(defect_params)

    if priority_id.present?
      defect.priority = Priority.find(priority_id)
      defect.set_target_completion_date
    else
      set_target_completion_date
    end

    set_actual_completion_date

    defect
  end

  private

  def set_target_completion_date
    date_parts = target_completion_date.values_at(:day, :month, :year)
    return unless date_parts.all?(&:present?)

    day, month, year = date_parts.map(&:to_i)
    date = Date.new(year, month, day)
    defect.set_target_completion_date(date)
  end

  def set_actual_completion_date
    date_parts = actual_completion_date.values_at(:day, :month, :year)
    return unless date_parts.all?(&:present?)

    day, month, year = date_parts.map(&:to_i)
    date = Date.new(year, month, day)
    defect.set_actual_completion_date(date)
  end
end
