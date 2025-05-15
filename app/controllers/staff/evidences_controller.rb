class Staff::EvidencesController < Staff::BaseController
  include DefectHelper

  def new
    @defect = Defect.find(defect_id)
    @evidence = Evidence.new
  end

  def create
    @defect = Defect.find(defect_id)
    @evidence = @defect.evidences.new(evidence_params)
    @evidence.user = current_user

    if @evidence.valid?
      @evidence.save
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'evidence')
      redirect_to defect_path_for(defect: @defect)
    else
      render :new
    end
  end

  private

  def defect_id
    params[:defect_id]
  end

  def evidence_params
    params.require(:evidence).permit(:supporting_file, :description)
  end
end
