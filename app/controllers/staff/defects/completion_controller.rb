class Staff::Defects::CompletionController < Staff::BaseController
  include DefectHelper

  def new
    @defect = Defect.find(id)
  end

  def create
    defect = Defect.find(id)

    @defect = EditDefect.new(
      defect: defect,
      defect_params: {},
      options: { actual_completion_date: actual_completion_date }
    ).call

    return render :new if @defect.invalid?

    UpdateDefect.new(defect: @defect).call

    flash[:success] = I18n.t('generic.notice.update.success', resource: 'defect')
    redirect_to defect_path_for(defect: @defect)
  end

  private

  def id
    params[:defect_id]
  end

  def actual_completion_date
    params.require(:actual_completion_date).permit(:day, :month, :year)
  end
end
