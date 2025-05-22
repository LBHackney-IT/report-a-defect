class Staff::Defects::ForwardingController < Staff::BaseController
  include DefectHelper

  def new
    @defect = Defect.find(id)
    @other_events = @defect.activities.where(key: "defect.forwarded_to_#{recipient_type}")
  end

  def create
    defect = Defect.find(id)

    case recipient_type
    when 'contractor'
      EmailContractor.new(defect: defect).call
    when 'employer_agent'
      EmailEmployerAgent.new(defect: defect).call
    end

    redirect_to defect_url_for(defect: defect),
                flash: {
                  success: I18n.t('page_content.defect.forwarding.success',
                                  recipient_type: formatted_recipient_type),
                }
  end

  helper_method :recipient_type
  def recipient_type
    params[:recipient_type]
  end

  helper_method :formatted_recipient_type
  def formatted_recipient_type
    recipient_type.tr('_', ' ')
  end

  private

  def id
    params[:defect_id]
  end
end
