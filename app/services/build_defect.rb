class BuildDefect
  attr_accessor :defect_params,
                :property_id,
                :priority_id

  def initialize(defect_params:, options: {})
    self.defect_params = defect_params
    self.property_id = options[:property_id]
    self.priority_id = options[:priority_id]
  end

  def call
    defect = Defect.new(defect_params)
    defect.property = Property.find(property_id) if property_id.present?
    defect.priority = Priority.find(priority_id) if priority_id.present?

    defect
  end
end
