class Staff::Defects::ForwardingController < Staff::BaseController
  include DefectHelper

  def new
    @defect = Defect.find(id)
    @other_events = @defect.activities.where(key: 'defect.forwarded_to_contractor')
  end

  def create
    defect = Defect.find(id)
    EmailContractor.new(defect: defect).call
    redirect_to defect_path_for(defect: defect),
                flash: { success: I18n.t('page_content.defect.forwarding.success') }
  end

  private

  def id
    params[:defect_id]
  end
end
