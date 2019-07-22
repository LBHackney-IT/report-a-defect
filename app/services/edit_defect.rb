class EditDefect
  attr_accessor :defect,
                :defect_params,
                :priority_id,
                :target_completion_date

  def initialize(defect:, defect_params:, options: {})
    self.defect = defect
    self.defect_params = defect_params
    self.priority_id = options[:priority_id]
    self.target_completion_date = options.fetch(:target_completion_date, {})
  end

  def call
    defect.assign_attributes(defect_params)

    if priority_id.present?
      defect.priority = Priority.find(priority_id)
      defect.set_completion_date
    else
      set_target_completion_date
    end

    NotifyDefectCompletedJob.perform_later(defect.id) if defect.status_changed? && defect.completed?
    defect
  end

  private

  def set_target_completion_date
    date_parts = target_completion_date.values_at(:day, :month, :year)
    return unless date_parts.all?(&:present?)

    day, month, year = date_parts.map(&:to_i)
    date = Date.new(year, month, day)
    defect.set_completion_date(date)
  end
end
