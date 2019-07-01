class Staff::CommunalDefectsController < Staff::BaseController
  def new
    @communal_area = CommunalArea.find(communal_area_id)
    @defect = Defect.new
  end

  def create
    @communal_area = CommunalArea.find(communal_area_id)

    options = { communal_area_id: communal_area_id, priority_id: priority_id }
    @defect = BuildDefect.new(defect_params: defect_params, options: options).call

    if @defect.valid?
      SaveCommunalDefect.new(defect: @defect).call
      flash[:success] = I18n.t('generic.notice.create.success', resource: 'defect')
      redirect_to communal_area_path(@communal_area)
    else
      render :new
    end
  end

  def show
    @defect = DefectPresenter.new(Defect.find(id))
  end

  def edit
    @defect = DefectPresenter.new(Defect.find(id))
  end

  def update
    defect = Defect.find(id)
    @defect = EditDefect.new(
      defect: defect,
      defect_params: defect_params,
      options: { priority_id: priority_id }
    ).call

    if @defect.valid?
      @defect.save
      flash[:success] = I18n.t('generic.notice.update.success', resource: 'defect')
      redirect_to communal_area_defect_path(@defect.communal_area, @defect)
    else
      render :edit
    end
  end

  private

  def id
    params[:id]
  end

  def communal_area_id
    params[:communal_area_id]
  end

  def priority_id
    params.require(:defect).permit(:priority)[:priority]
  end

  def defect_params
    params.require(:defect).permit(
      :title,
      :access_information,
      :description,
      :contact_name,
      :contact_email_address,
      :contact_phone_number,
      :trade,
      :status
    )
  end
end
