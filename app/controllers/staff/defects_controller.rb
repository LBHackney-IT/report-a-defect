class Staff::DefectsController < Staff::BaseController
  helper_method :open_status?,
                :closed_status?,
                :type_property?,
                :type_communal?,
                :escalated_manually?,
                :escalated_overdue?,
                :escalated_due_soon?,
                :selected_scheme?
  def index
    @defect_filter = DefectFilter.new(
      statuses: statuses,
      types: types,
      schemes: scheme_ids,
      escalations: escalations,
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

  def open_status?
    return false if statuses.blank?

    statuses.include?(:open)
  end

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

  def type_property?
    return false if types.blank?

    types.include?(:property)
  end

  def type_communal?
    return false if types.blank?

    types.include?(:communal)
  end

  def escalated_manually?
    return false if escalations.blank?

    escalations.include?(:manually_escalated)
  end

  def escalated_overdue?
    return false if escalations.blank?

    escalations.include?(:overdue)
  end

  def escalated_due_soon?
    return false if escalations.blank?

    escalations.include?(:due_soon)
  end

  def scheme_ids
    params.fetch(:scheme_ids, [])
  end

  def selected_scheme?(scheme_id)
    return false if scheme_id.blank?

    scheme_ids.include?(scheme_id)
  end
end
