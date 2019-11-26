class BuildDefect < DefectBuilder
  attr_accessor :communal_area_id,
                :property_id,
                :user

  def initialize(defect_params:, options: {})
    self.defect_params = defect_params
    self.property_id = options[:property_id]
    self.communal_area_id = options[:communal_area_id]
    self.priority_id = options[:priority_id]
    self.created_at = options[:created_at]
    self.user = options[:user]
  end

  def call
    self.defect = Defect.new(defect_params)
    defect.property = Property.find(property_id) if property_id.present?
    defect.communal_area = CommunalArea.find(communal_area_id) if communal_area_id.present?
    defect.priority = Priority.find(priority_id) if priority_id.present?
    defect.set_target_completion_date

    set_created_at if created_at.present?
    set_evidence_user

    defect
  end

  private

  def set_evidence_user
    defect.evidences.first.user = user if defect.evidences.present?
  end
end
