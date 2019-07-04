class Staff::DefectsController < Staff::BaseController
  def index
    @defect_filter = DefectFilter.new(statuses: statuses)
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
end
