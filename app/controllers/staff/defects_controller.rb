class Staff::DefectsController < Staff::BaseController
  def index
    @defect_filter = DefectFilter.new(
      statuses: statuses,
      types: types,
      schemes: scheme_ids,
    )
    @defects = DefectFinder.new(order: :target_completion_date, filter: @defect_filter)
                           .call
                           .map { |defect| DefectPresenter.new(defect) }
  end

  private

  def statuses
    params.fetch(:statuses, [])
          .map { |status| status.parameterize.underscore.to_sym }
  end

  helper_method :open_status?
  def open_status?
    return false if statuses.blank?
    statuses.include?(:open)
  end

  helper_method :closed_status?
  def closed_status?
    return false if statuses.blank?
    statuses.include?(:closed)
  end

  def types
    params.fetch(:types, [])
          .map { |type| type.parameterize.underscore.to_sym }
  end

  def escalations
    params.fetch(:escalations, [])
          .map { |escalation| escalation.parameterize.underscore.to_sym }
  end

  helper_method :type_property?
  def type_property?
    return false if types.blank?
    types.include?(:property)
  end

  helper_method :type_communal?
  def type_communal?
    return false if types.blank?
    types.include?(:communal)
  end

  helper_method :escalated_escalated?
  def escalated_escalated?
    return false if escalations.blank?
    escalations.include?(:escalated)
  end

  helper_method :escalated_overdue?
  def escalated_overdue?
    return false if escalations.blank?
    escalations.include?(:overdue)
  end

  helper_method :escalated_due_soon?
  def escalated_due_soon?
    return false if escalations.blank?
    escalations.include?(:due_soon)
  end

  def scheme_ids
    params.fetch(:scheme_ids, [])
  end

  helper_method :selected_scheme?
  def selected_scheme?(scheme_id)
    return false if scheme_id.blank?
    scheme_ids.include?(scheme_id)
  end
end
