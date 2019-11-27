class EditDefect < DefectBuilder
  attr_accessor :target_completion_date,
                :actual_completion_date

  def initialize(defect:, defect_params:, options: {})
    self.defect = defect
    self.defect_params = defect_params
    self.priority_id = options[:priority_id]
    self.target_completion_date = options.fetch(:target_completion_date, {})
    self.actual_completion_date = options.fetch(:actual_completion_date, {})
    self.created_at = options.fetch(:created_at, {})
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
    set_created_at if created_at.present?

    defect
  end

  private

  def set_target_completion_date
    date = BuildDate.new(target_completion_date).call
    defect.set_target_completion_date(date) if date.present?
  end

  def set_actual_completion_date
    date = BuildDate.new(actual_completion_date).call
    defect.set_actual_completion_date(date) if date.present?
  end
end
