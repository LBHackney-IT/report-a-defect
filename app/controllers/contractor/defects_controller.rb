class Contractor::DefectsController < Contractor::BaseController
  def accept
    defect_id = MessageVerifier.verifier.verify(defect_token, purpose: :accept_defect_ownership)
    @defect = Defect.find(defect_id)
    @defect.create_activity(key: 'defect.accepted')
  end

  def defect_token
    params[:defect_id]
  end
end
