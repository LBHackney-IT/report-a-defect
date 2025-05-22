class Staff::DefectFlagsController < Staff::BaseController
  def create
    defect.update!(flagged: true)
    redirect_to helpers.defect_url_for(defect: defect)
  end

  def destroy
    defect.update!(flagged: false)
    redirect_to helpers.defect_url_for(defect: defect)
  end

  private

  def defect
    @defect ||= Defect.find(params[:defect_id])
  end
end
