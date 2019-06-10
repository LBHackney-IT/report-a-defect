class Contractor::DefectsController < Contractor::BaseController
  def accept
    defect_id = MessageVerifier.verifier.verify(defect_token, purpose: :accept_defect_ownership)
    @defect = Defect.find(defect_id)

    if @defect.activities.find_by(key: 'defect.accepted')
      render 'unprocessable_entity', status: :unprocessable_entity
    else
      @defect.create_activity(key: 'defect.accepted')
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render 'unprocessable_entity', status: :unprocessable_entity
  end

  def defect_token
    params[:defect_id]
  end
end
