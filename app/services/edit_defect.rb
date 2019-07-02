class EditDefect
  attr_accessor :defect,
                :defect_params,
                :priority_id

  def initialize(defect:, defect_params:, options: {})
    self.defect = defect
    self.defect_params = defect_params
    self.priority_id = options[:priority_id]
  end

  def call
    defect.assign_attributes(defect_params)

    if priority_id.present?
      defect.priority = Priority.find(priority_id)
      defect.set_completion_date
    end

    defect
  end
end
